# [Phase 0] 位置情報プライバシー対応と信頼の土台整備 — 技術仕様

対象 Issue: [#104](https://github.com/Mottttton/yaeh_map/issues/104)（Parent: [#103](https://github.com/Mottttton/yaeh_map/issues/103)）
対象: backend（Rails 8 API）+ frontend（Vue 3 SPA）

> 収益化（AdSense 審査・スポンサー営業）の前提として、位置情報プライバシーと UGC としての信頼性を担保する。本書は #104 の 4 領域（位置精度選択 / EXIF strip / 通報・モデレーション / 規約整備）の実装仕様と、PR 単位の子 Issue 分割を定める。

## 0. 方針の決定事項

- **おおまか / 位置なしの投稿では `place` を保存しない**（nil にする）。座標を丸めても正確な地名が残ると位置が漏れるため。表示は都道府県 + 丸め座標のみ
- **通報は管理画面での手動対応のみ**。メール通知・件数による自動非表示は実装しない
- **利用規約・プライバシーポリシーは日本語ドラフトまで作成**する（本書では章立てと必須記載事項を規定）
- **新規 enum のキーは英語**とする（既存の `genre` 等は日本語キーだが踏襲しない）。日本語表示ラベルは i18n（`config/locales/ja.yml`）で供給し、meta API が `{ label, value }` 形式で配信する

## 1. 位置精度選択

### 1.1 データモデル

```ruby
# app/models/post.rb
enum :location_accuracy, { exact: 0, approximate: 1, no_location: 2 }, prefix: true
```

- 表示ラベル: exact=正確 / approximate=おおまか / no_location=位置なし（`ja.yml` の `enums.post.location_accuracy.*`）
- `none` は `Post.none`（ActiveRecord の null relation）とスコープ名が衝突するため **`no_location`** を採用
- API の授受は英語キー文字列（`"exact"` 等）で行い、表示のみ日本語ラベルを使う

マイグレーション（1 本にまとめる）:

```ruby
add_column :posts, :location_accuracy, :integer, null: false, default: 0
change_column_default :posts, :location_accuracy, from: 0, to: 1
change_column_null :posts, :latitude,  true
change_column_null :posts, :longitude, true
change_column_null :posts, :place,     true  # おおまか/位置なしで place を保存しないため必須
```

- `default: 0` で追加することで既存投稿は「正確」にバックフィルされる。その後 default を `1`（approximate）へ変更し、**新規レコードの未指定時は安全側の「おおまか」**とする（PR #121 レビュー反映）
- `place` の NOT NULL 解除は見落としやすいので注意（現 schema は `t.string "place", null: false`）

### 1.2 丸めアルゴリズム: グリッドスナップ 0.01 度

```ruby
COARSE_GRID_STEP = 0.01  # 緯度 ≈ 1.1km / 経度 ≈ 0.9km（北緯35度付近）

def round_coordinate(value)
  (value / COARSE_GRID_STEP).round * COARSE_GRID_STEP
end
```

ランダムオフセット方式と比較しグリッドスナップを採用する理由:

| 観点 | グリッドスナップ（採用） | ランダムオフセット |
|---|---|---|
| 決定論性 | 冪等（`round(round(x)) == round(x)`） | 毎回変わる。決定論化には投稿ごとのシード保存が必要 |
| 再編集時 | 地図に触れず更新しても座標が動かない | 保存のたびにピンが動く / シード管理が増える |
| プライバシー | 真の位置は該当セル内（±約500m）と分かるのみ | 複数回の観測平均で真位置が推定され得る |
| 実装コスト | 数行 | シードカラム等が必要 |

冪等性により「おおまか投稿の再編集時、丸め済み座標しか返せない」問題が構造的に消える。サーバは丸め後の値しか返さず、本人が再送信しても値が安定するため、本人向けの生座標返却経路は作らない。

### 1.3 実装位置: モデルの `before_validation`

```ruby
# app/models/post.rb
before_validation :apply_location_accuracy

validates :place, presence: true, if: :location_accuracy_exact?
validates :latitude, :longitude, presence: true, unless: :location_accuracy_no_location?
# 現行の place / latitude / longitude の無条件 presence は上記に置き換える

private

def apply_location_accuracy
  case
  when location_accuracy_approximate?
    self.latitude  = round_coordinate(latitude)  if latitude
    self.longitude = round_coordinate(longitude) if longitude
    self.place = nil
  when location_accuracy_no_location?
    self.latitude = nil
    self.longitude = nil
    self.place = nil
  end
end
```

- **`before_validation`**（`before_save` でなく）: 丸め・クリア後の最終状態に対して条件付きバリデーションが走り、整合性が 1 箇所で閉じる
- **モデル層**（controller / service でなく）: 書き込み経路がどこであっても DB 保存前の丸めを保証（「丸めはサーバ側（DB 保存前）」の要件を強制）。ロジックは 10 行程度で service は過剰
- `place = nil` をサーバ側で強制するため、フロントが place を送っても保存されない
- `prefecture` / `region` はそのまま保存する（位置なし投稿の地域表示・検索に使う）

### 1.4 API 変更

- `posts_controller#post_params` に `:location_accuracy` を追加
- `PostSerializer.card` に `location_accuracy: post.location_accuracy` を追加。`latitude / longitude / place` の返却コードは変更不要 — **生座標はそもそも DB に保存されない**ため、シリアライザ経由の漏洩が構造的に起き得ない（これが「API レスポンスに生座標を含めない」の実装方針）
- `meta_controller#show` に `location_accuracies`（`{ label: "正確", value: "exact" }` 形式）を追加
- `ransackable_attributes` は変更不要（丸め済み値しか無いので `latitude_gt` 等で探られても漏れない）

### 1.5 フロントエンド

- `types/index.ts`: `Post` を `latitude: number | null` / `longitude: number | null` / `place: string | null` に変更し `location_accuracy: string` を追加。`MetaResponse` に `location_accuracies: MetaOption[]`
- `api/index.ts` の `PostPayload`: `location_accuracy: string` を追加、`latitude / longitude` を null 許容に
- `PostForm.vue`: genre と同型の RadioGroup を MapPicker の直上に追加（meta から生成）。「位置なし」選択時は MapPicker を無効化し座標・place をクリア。都道府県 select は従来通り手動選択可能（位置なし投稿の地域決定手段になる）。「おおまか」選択時は補足文「地図のピン位置は約1km単位に丸めて保存・表示されます」を表示
- `MapPicker.vue`: `disabled?: boolean` prop を追加。true のとき地図に overlay（`pointer-events-none` + 半透明）をかけ、クリック / 検索 / 現在地を無効化
- `PostCard.vue`: 地図画像は `post.latitude != null` ガード付きに変更。位置なしは既存の MapPin アイコン + 地名フォールバック分岐を流用。おおまか投稿は static map の zoom を落とし「おおまか」Badge を付けて精度誤認を防ぐ
- `PostShowView.vue`: 位置なし → 地図セクション非表示・都道府県テキストのみ。おおまか → `place`（place_id）が無いため既存の `embedMapUrl` は使えず、`utils/googleMaps.ts` に view モードの `embedViewUrl(lat, lng, zoom)` を追加して分岐。外部リンクは丸め座標で従来通り
- 全投稿マーカーの一覧地図ビューは存在しないため、「位置なしは地図非表示・フィードのみ」は上記カード / 詳細の分岐で完結する

## 2. 写真の EXIF strip

### 2.1 方針: 全メタデータ除去

GPS のみの外科的除去は不採用。EXIF には GPS 以外にもシリアル番号・所有者名等が含まれ、XMP / IPTC 側にも位置情報が入り得る。全除去 + 再エンコードが最も確実で、副次効果として不正な画像構造も無害化される。

### 2.2 実装: `app/services/image_sanitizer.rb`（新設）

```ruby
ImageProcessing::Vips
  .source(uploaded_file.tempfile)
  .loader(autorotate: true)     # 必須: Orientation もメタデータ。除去前に回転を焼き込む
  .saver(strip: true, quality: 90)
  .call
```

- **autorotate が最重要の落とし穴**: strip だけ行うと EXIF Orientation が失われ、スマホ写真が横倒しになる
- JPEG: 再エンコード（quality 90）。閲覧はほぼ variant（400x300）経由のため画質影響は実用上無視できる。ICC プロファイル剥離による色変化（iPhone の Display-P3 等）は、同梱 libvips が対応バージョンなら ICC のみ温存を検討。不可なら全 strip で妥協（仕様として許容）
- PNG: `strip: true` で eXIf / tEXt チャンクを除去。可逆のため劣化なし
- content_type / filename は変更しない

適用は **2 経路**（無加工オリジナルが保存される入口がこの 2 つ）:

1. `uploads_controller#create` — `create_and_upload!` の `io:` に渡す前にサニタイズ。投稿写真とプロフィール画像更新（signed_id 経由）はここで全てカバー
2. `registrations_controller#create` — **サインアップ時の portrait は uploads API を通らず生ファイル直渡し**（`SignupView.vue` が `account[portrait]` を FormData 送信）のため、同 service を適用。見落とすと片穴が残る

**失敗時はフェイルクローズ**: vips が例外を投げたら（破損ファイル等）オリジナルを保存せず 422（「画像を処理できませんでした」）を返す。フォールバックで無加工保存すると「EXIF は除去される」という規約上の約束が破れるため。

## 3. 通報・モデレーション

### 3.1 Report モデル

```ruby
create_table :reports do |t|
  t.references :reporter, null: false, foreign_key: { to_table: :accounts }
  t.references :reportable, polymorphic: true, null: false  # Post / Account
  t.integer :reason, null: false
  t.text :description                                       # 任意・500字まで
  t.integer :status, null: false, default: 0
  t.timestamps
end
add_index :reports, [:reporter_id, :reportable_type, :reportable_id], unique: true
add_index :reports, :status
```

```ruby
class Report < ApplicationRecord
  belongs_to :reporter, class_name: "Account"
  belongs_to :reportable, polymorphic: true

  enum :reason, {
    spam: 0,                      # スパム
    inappropriate: 1,             # 不適切な内容
    privacy_violation: 2,         # 個人情報・プライバシーの侵害
    dangerous_misinformation: 3,  # 危険・虚偽の情報
    other: 4                      # その他
  }, prefix: true
  enum :status, { pending: 0, resolved: 1, dismissed: 2 }, prefix: true
  # pending=未対応 / resolved=対応済み / dismissed=対応不要（確認したが問題なし）

  validates :reason, presence: true
  validates :description, length: { maximum: 500 }
  validates :reporter_id, uniqueness: { scope: %i(reportable_type reportable_id) }
  validate :cannot_report_own_content
end
```

- 日本語ラベルは i18n（`enums.report.reason.*` / `enums.report.status.*`）
- 重複通報防止は DB unique index + uniqueness バリデーションの二重化。解除後の再通報は Phase 0 では不可（手動運用なので admin が status を戻せば足りる）
- 自分の投稿 / 自分自身の通報は 422
- Post / Account に `has_many :received_reports, as: :reportable, dependent: :destroy`、Account に `has_many :reports, foreign_key: :reporter_id, dependent: :destroy`。対象削除時に通報も消える（削除＝対応完了とみなす）

### 3.2 非表示状態: `hidden_at`（datetime）

posts / accounts 両テーブルに `t.datetime :hidden_at`（NULL 可、NULL＝表示中）を追加。boolean と実装コストは同じだが「いつ非表示にしたか」が残り、通報との突き合わせ・問い合わせ対応で必要になるため datetime を採用。

```ruby
scope :visible, -> { where(hidden_at: nil).where(account_id: Account.where(hidden_at: nil)) }
```

適用箇所:

- `posts#index`: admin 以外は `Post.visible` を起点にする（投稿者アカウントが非表示なら投稿も不可視）
- `posts#show`: 非表示投稿は owner / admin 以外に 404（存在秘匿）。owner には閲覧を許し、シリアライザに `hidden` フラグを追加してフロントで注意表示（自分の投稿が黙って消えると問い合わせが増えるため）
- `accounts#show`: 非表示アカウントは admin 以外に 404
- `favorites_controller` の `Post.find` も visible 経由に変更

### 3.3 ルーティング / コントローラ

favorites の nested resource パターンに揃える:

```ruby
resources :posts do
  resource :report, only: :create, controller: "reports"   # POST /api/v1/posts/:post_id/report
end
resources :accounts, only: %i(show update) do
  resource :report, only: :create, controller: "reports"   # POST /api/v1/accounts/:account_id/report
end

namespace :admin do
  resources :accounts, only: %i(index destroy) do
    member { patch :hide; patch :unhide }
  end
  resources :posts, only: [] do
    member { patch :hide; patch :unhide }
  end
  resources :reports, only: %i(index update)                # update は status のみ
end
```

- `ReportsController` は `params[:post_id]` / `params[:account_id]` から reportable を解決する 1 本のコントローラ
- `Admin::ReportsController#index`: status フィルタ（デフォルト pending）、`includes(:reporter, :reportable)`、作成日降順、kaminari ページング。レスポンスは既存 `Admin::AccountsController` と同様のインライン JSON（reportable の種別・タイトル / 名前・id・hidden 状態を含む）
- meta API に `report_reasons` を追加（通報フォームの選択肢用）。status のラベルも meta に含める（admin 画面用）
- 通知・自動非表示・件数トリガは実装しない（決定事項）

### 3.4 フロントエンド

- `ReportSheet.vue`（新規）: Sheet（導入済み。モーダル未導入のため）+ reason の RadioGroup + description の Textarea + 送信。props で `target: { type: 'post' | 'account', id }`。成功で flash、通報済み（422）はエラーメッセージ表示
- 設置場所: `PostShowView.vue`（非オーナーのみ）と `AccountShowView.vue`（他人のみ）。PostCard には置かない（カードの操作を増やさず詳細ページへ誘導）
- `api/index.ts` に `reportsApi = { reportPost, reportAccount }` を追加
- 管理画面: `/admin/reports` ルート（adminOnly）+ `AdminReportsView.vue` を新設。既存 Table コンポーネントで一覧（対象リンク・理由・詳細・通報者・日時・status 変更・非表示 / 再表示・削除）。既存 `/admin`（アカウント一覧）とはタブリンクで相互遷移。`adminApi` に reports index / update、posts / accounts の hide / unhide を追加

## 4. 利用規約・プライバシーポリシー

### 4.1 実装

- ルート: `/terms`・`/privacy`（`meta: { public: true }`、未ログイン閲覧可）。`TermsView.vue` / `PrivacyPolicyView.vue` に本文を直接記述（この規模で CMS / markdown ローダは過剰。改定は PR レビューで管理し、施行日を本文に明記する運用）。共通の記事レイアウト（max-w-3xl、見出し階層）のみ揃える
- `App.vue` の footer に「利用規約 | プライバシーポリシー」リンクを追加
- `SignupView.vue` の送信ボタン付近に「登録することで利用規約およびプライバシーポリシーに同意したものとみなします」+ リンクを追加（同意チェックボックス + 同意日時の DB 記録は Phase 0 スコープ外）

### 4.2 章立て（日本語ドラフトは子 Issue で本文まで書く）

**利用規約**:
1. 適用 / 2. 定義 / 3. アカウント登録・管理 / 4. 投稿コンテンツ（UGC）の権利と責任（投稿者に権利留保、サービス表示に必要なライセンス許諾） / 5. 位置情報の取扱い（精度選択・丸め仕様・「正確」選択時の自己責任） / 6. 禁止事項（他者の位置プライバシー侵害、虚偽の危険情報等を含む） / 7. 通報と措置（非表示・削除・アカウント停止、運営の裁量と免責） / 8. Google マップの利用（Google 利用規約・Google Maps/Google Earth 追加利用規約への同意） / 9. 免責事項（投稿情報の正確性、走行判断は自己責任） / 10. サービスの変更・終了 / 11. 規約の変更 / 12. 準拠法・管轄

**プライバシーポリシー**:
1. 取得する情報（アカウント情報 / 投稿情報 / 位置情報 / 写真 / Cookie（セッション Cookie のみ）） / 2. 位置情報の取扱い（精度選択、「おおまか」は約1km丸め後のみ保存し元座標は保存しない、「位置なし」は座標を保存しない） / 3. 写真のメタデータ（EXIF 等は保存前に削除する） / 4. 利用目的 / 5. 第三者提供・外部送信（Google Maps Platform への送信、Google のプライバシーポリシーへの参照） / 6. 安全管理措置 / 7. 保存期間・削除（退会時の扱い） / 8. 開示・訂正・削除の請求方法 / 9. 改定 / 10. お問い合わせ窓口

## 5. テスト方針

- **既存への影響**: posts factory は default「approximate」でそのまま valid（place はクリアされる）。「location_accuracy 未指定＝おおまか（安全側）」を request spec で明示的に固定。model spec の座標 presence 期待（nil でエラー）は条件付きに書き換え、place 必須のテストは exact を明示。E2E 用 ID は変更しない
- **追加 spec**:
  - model: 丸めの決定論・冪等性、精度別の place / 座標クリア、条件付き presence、`visible` スコープ、Report の重複 / 自己通報バリデーション
  - request: 精度別 create / update（おおまかのレスポンス座標が丸め済みであること＝生座標非返却の回帰テスト）、uploads の EXIF 除去（ruby-vips でフィールド検査）、reports 作成系、admin reports / hide 系、非表示投稿の 404 / 一覧除外（owner / admin 例外含む）
  - fixture: GPS EXIF + Orientation 付き JPEG を `spec/fixtures/files/` に追加

## 6. 子 Issue 分割（PR 単位）

依存関係:

```
① 位置精度BE ──→ ② 位置精度FE
④ 通報BE ──→ ⑤ 非表示+管理BE ──→ ⑥ 通報・管理FE
③ EXIF strip（独立）    ⑦ 規約ページ（独立、①③の仕様確定後に本文推奨）
```

| # | タイトル | 依存 | スコープ概要 |
|---|---|---|---|
| ① | [BE] 投稿の位置精度選択（カラム・丸め・API） | なし | migration / モデル / params / serializer / meta / spec |
| ② | [FE] 投稿フォーム・表示の位置精度対応 | ① | 型 null 許容化 / RadioGroup / MapPicker disabled / カード・詳細分岐 |
| ③ | [BE] 画像アップロード時のメタデータ除去 | なし | ImageSanitizer / 2 経路適用 / fixture / spec |
| ④ | [BE] 通報モデルと通報 API | なし | Report / 通報エンドポイント / meta |
| ⑤ | [BE] 非表示状態と管理 API | ④ | hidden_at / visible スコープ / admin reports・hide API |
| ⑥ | [FE] 通報 UI と管理画面拡張 | ⑤ | ReportSheet / AdminReportsView / adminApi |
| ⑦ | [FE/Docs] 利用規約・プライバシーポリシー | なし | ページ + 日本語文面ドラフト + footer + signup 文言 |

リリース順の推奨: ①→② を最優先（プライバシーの実害に直結）、③ は並行、④→⑤→⑥、⑦ は ①③ の仕様確定後に本文を書くと記載内容が確定していて手戻りがない。

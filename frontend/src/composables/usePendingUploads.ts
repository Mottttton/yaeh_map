import { onBeforeUnmount, onMounted } from 'vue'
import { onBeforeRouteLeave } from 'vue-router'

// 「アップロード済みだが保存が確定していない」画像の離脱ガード。
// - アプリ内のルート遷移: confirm で警告し、それでも離れる場合は未確定の blob を削除する
// - リロード・タブを閉じる等: ブラウザ標準の離脱警告を出し、離脱確定時(pagehide)に削除する
export function usePendingUploadsGuard(options: {
  message: string
  /** 未確定アップロードの signed_id 一覧。空なら警告しない */
  pendingSignedIds: () => string[]
  /** 破棄が確定したときの後始末（ObjectURL の解放など） */
  onDiscard?: () => void
}) {
  const hasPending = () => options.pendingSignedIds().length > 0

  onBeforeRouteLeave(() => {
    if (!hasPending()) return true
    if (!window.confirm(options.message)) return false
    discardUploads(options.pendingSignedIds())
    options.onDiscard?.()
    return true
  })

  function onBeforeUnload(event: BeforeUnloadEvent) {
    if (!hasPending()) return
    // ブラウザ標準の「変更が保存されない可能性があります」ダイアログを表示する
    event.preventDefault()
  }

  function onPageHide(event: PageTransitionEvent) {
    // bfcache に入る場合は戻ってくる可能性があるため削除しない
    if (event.persisted || !hasPending()) return
    discardUploads(options.pendingSignedIds())
  }

  onMounted(() => {
    window.addEventListener('beforeunload', onBeforeUnload)
    window.addEventListener('pagehide', onPageHide)
  })
  onBeforeUnmount(() => {
    window.removeEventListener('beforeunload', onBeforeUnload)
    window.removeEventListener('pagehide', onPageHide)
  })
}

// 未確定アップロードを破棄する。ページ離脱中でも送信が完了するよう keepalive 付き fetch を使う
// （axios は XHR ベースのため unload 中の送信が保証されない）
export function discardUploads(signedIds: string[]) {
  const token = csrfToken()
  signedIds.forEach((signedId) => {
    void fetch(`/api/v1/uploads/${encodeURIComponent(signedId)}`, {
      method: 'DELETE',
      keepalive: true,
      headers: { 'X-CSRF-Token': token }
    }).catch(() => {
      // 削除に失敗しても UX は妨げない（バックエンドの storage:purge_unattached が掃除する）
    })
  })
}

function csrfToken(): string {
  const match = document.cookie.match(/(?:^|;\s*)CSRF-TOKEN=([^;]+)/)
  return match ? decodeURIComponent(match[1]) : ''
}

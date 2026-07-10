namespace :storage do
  desc "Active Storage が S3 互換ストレージを使う場合にバケットを作成する（存在すれば何もしない）"
  task prepare: :environment do
    service = ActiveStorage::Blob.service
    next unless service.respond_to?(:bucket)

    # ストレージコンテナの起動を少し待つ
    attempts = 0
    begin
      service.bucket.create unless service.bucket.exists?
      puts "storage:prepare: bucket '#{service.bucket.name}' is ready"
    rescue Seahorse::Client::NetworkingError, Aws::S3::Errors::ServiceError => e
      attempts += 1
      raise if attempts > 10

      sleep 2
      retry
    end
  end
end

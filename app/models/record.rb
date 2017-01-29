class Record < ApplicationRecord

  def self.last_updated_at
    Record.order(:updated_at).select(:updated_at).last&.updated_at
  end

  def self.fetch(date = Time.now.in_time_zone('Asia/Tokyo').to_date)
    # 未来のデータは存在しない
    if date > Time.now.in_time_zone('Asia/Tokyo').to_date
      return nil
    end
    # DBを調べる
    record = Record.find_by(date:date)
    # DBに存在する
    if record
      # 当該日の最終データまで完全に保存されている場合はDBから返却
      if record.updated_at.utc >= record.date.tomorrow.to_time.utc
        return record
      end
      # 鳥取県のウェブサイトには6日前までしかデータを公開していない
      # その日よりも前のデータは存在しないので不完全なデータであってもDBから返却
      if date < Time.now.ago(6.days).in_time_zone('Asia/Tokyo').to_date
        return record
      end
      # データ取得
      ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
      data = Tottori::OpenData::PM25::API.get(date.in_time_zone('Asia/Tokyo')).to_json
      # DB更新
      record.update(data:data)
      return record
    end
    # DBに存在しない
    if !record
      # 鳥取県のウェブサイトには6日前までしかデータを公開していない
      # その日よりも前のデータは存在しない
      if date < Time.now.ago(6.days).in_time_zone('Asia/Tokyo').to_date
        return nil
      end
      # データ取得
      ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
      data = Tottori::OpenData::PM25::API.get(date.in_time_zone('Asia/Tokyo')).to_json
      # DB追加
      record = Record.new(date:date, data:data)
      record.save
      return record
    end
  end

end

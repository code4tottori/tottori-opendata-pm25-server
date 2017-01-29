class Record < ApplicationRecord

  def self.last_updated_at
    Record.order(:updated_at).select(:updated_at).last&.updated_at
  end

  def self.get_current_data
    time = Time.now.in_time_zone('Asia/Tokyo')
    t2 = Time.iso8601(time.ago(1.hour).strftime('%Y-%m-%dT%H:00:00.000+09:00'))
    date = time.to_date
    record = Record.get(date)
    values = {}
    JSON.parse(record.data).each do |entry|
      entry_name = entry['name']
      entry_values = entry['values']
      entry_values.each do |entry_value|
        entry_time = entry_value['time']
        entry_value = entry_value['value']
        t1 = Time.iso8601(entry_time)
        if entry_value && t1 == t2
          values[entry_name] = entry_value
        end
      end
    end
    return {
      names: values.keys,
      time: t2,
      values: values,
    }
  end

  def self.get(date = Time.now.in_time_zone('Asia/Tokyo').to_date)
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
      data = Record.fetch_data(date)
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
      data = Record.fetch_data(date)
      # DB追加
      record = Record.new(date:date, data:data)
      record.save
      return record
    end
  end

  def self.fetch_data(date)
    ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
    Tottori::OpenData::PM25::API.get(date.in_time_zone('Asia/Tokyo')).to_json
  end

end

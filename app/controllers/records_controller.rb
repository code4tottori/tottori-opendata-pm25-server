class RecordsController < ApplicationController

  # GET /records/
  def index
  end

  # GET /records/graph.json
  def graph
    # build tidy data
    data = {}
    Record.all.each do |record|
      JSON.parse(record.data).each do |entry|
        entry_name = entry['name']
        entry_values = entry['values']
        entry_values.each do |entry_value|
          entry_time = entry_value['time']
          entry_value = entry_value['value']
          row = {
            name: entry_name,
            time: entry_time,
            value: entry_value,
          }
          if row[:value]
            data[row[:time]] ||= {}
            data[row[:time]][row[:name]] ||= row[:value]
          end
        end
      end
    end
    # build json
    json = {}
    json[:names] = data.values.map(&:keys).uniq.flatten.uniq
    data.keys.sort.each do |time|
      values = data[time]
      values.merge!(time:time)
      json[:values] ||= []
      json[:values] << values
    end
    # render json
    render json:json.to_json
  end

  # GET /records/today.json
  def today
    params[:date] = Time.now.in_time_zone('Asia/Tokyo').strftime('%Y%m%d')
    show
  end

  # GET /records/20170124.json
  def show
    @date = Date.parse(params[:date])
    # 未来のデータは存在しないので404
    if @date > Time.now.in_time_zone('Asia/Tokyo').to_date
      render json:{}, status: :not_found and return
    end
    # DBを調べる
    @record = Record.find_by(date:@date)
    # DBに存在する
    if @record
      # 当該日の最終データまで完全に保存されている場合はDBから返却
      if @record.updated_at.utc >= @record.date.tomorrow.to_time.utc
        render json:@record.data and return
      end
      # 鳥取県のウェブサイトには6日前までしかデータを公開していない
      # その日よりも前のデータは存在しないので不完全なデータであってもDBから返却
      if @date < Time.now.ago(6.days).in_time_zone('Asia/Tokyo').to_date
        render json:@record.data and return
      end
      # データ取得
      ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
      @data = Tottori::OpenData::PM25::API.get(@date.in_time_zone('Asia/Tokyo')).to_json
      # DB更新
      if @record.update(data:@data)
        render json:@record.data, status: :ok and return
      else
        render json:@record.errors, status: :unprocessable_entity and return
      end
    end
    # DBに存在しない
    if !@record
      # 鳥取県のウェブサイトには6日前までしかデータを公開していない
      # その日よりも前のデータは存在しないので404
      if @date < Time.now.ago(6.days).in_time_zone('Asia/Tokyo').to_date
        render json:{}, status: :not_found and return
      end
      # データ取得
      ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
      @data = Tottori::OpenData::PM25::API.get(@date.in_time_zone('Asia/Tokyo')).to_json
      # DB追加
      @record = Record.new(date:@date, data:@data)
      if @record.save
        render json:@record.data, status: :created and return
      else
        render json:@record.errors, status: :unprocessable_entity and return
      end
    end
  rescue ArgumentError => e
    render json:e.to_json, status: :unprocessable_entity and return
  end

end

class RecordsController < ApplicationController

  # GET /records/
  def index
  end

  # GET /records/update.json
  def update
    key = 'APP_ACCESS_SECRET'
    if params[key.downcase] && ENV[key] && params[key.downcase] == ENV[key]
      # update data
      Record.get(Date.parse(Time.now.in_time_zone('Asia/Tokyo').strftime('%Y%m%d')))
      # tweet data
      TweetJob.perform_later
      # return ok
      render json:[], status: :ok
    else
      render json:[], status: :not_found
    end
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
    @record = Record.get(@date)
    if @record
      if @record.errors.empty?
        render json:@record.data, status: :ok and return
      else
        render json:@record.errors, status: :unprocessable_entity and return
      end
    else
      render json:[], status: :not_found and return
    end
  rescue ArgumentError => e
    render json:e.to_json, status: :unprocessable_entity and return
  end

end

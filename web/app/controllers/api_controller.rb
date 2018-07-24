require 'reloader/sse'

class ApiController < ApplicationController
  include ActionController::Live

  skip_before_action :verify_authenticity_token
  if Rails.env.production?
    http_basic_authenticate_with name: Rails.application.secrets['QSP_ANALYZER_OYENTE_USERNAME'], password: Rails.application.secrets['QSP_ANALYZER_OYENTE_PASSWORD']
  end

  def analyze
    threads = []
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Reloader::SSE.new(response.stream)

    @sources = {}
    @output = {}

    if bytecode_exists?
      @sources[:error] = "Error"
      return
    end

    @sources[:current_file] = oyente_params[:current_file]
    unless check_params
      @sources[:error] = "Invalid input"
    else
      FileUtils::mkdir_p "tmp/contracts"
      current_filename = oyente_params[:current_file].split("/")[-1]
      dir_path = Dir::Tmpname.make_tmpname "tmp/contracts/#{current_filename}", nil
      sources = eval(oyente_params[:sources])
      structure_files sources, dir_path
      file = File.open("#{dir_path}/#{oyente_params[:current_file]}", "r")
      begin
        threads <<  Thread.new {
          while (@output.empty?)
            sse.write({ :time => Time.now })
            sleep 1
          end
        }

        threads << Thread.new {
          output = oyente_cmd(file.path, "#{options} -a -rp #{dir_path}")
          @output = JSON.parse(output)
          sse.write({:sources => @output})
          UserMailer.analyzer_result_notification(dir_path, @output, oyente_params[:email]).deliver_later unless oyente_params[:email].nil?
        }
        threads.each &:join
        return render @output
      rescue
        @output[:error] = "Error"
      ensure
        file.close
        sse.close
      end
    end
  end

  def analyze_bytecode
    threads = []
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Reloader::SSE.new(response.stream)

    @contract = {}
    @output = {}

    unless bytecode_exists?
      @contract[:error] = "Error"
      return
    end

    unless check_params
      @contract[:error] = "Invalid input"
      return
    end

    FileUtils::mkdir_p "tmp/contracts"
    dir_path = "tmp/contracts/bytecode_#{request.remote_ip}"
    FileUtils::mkdir_p dir_path
    filepath = Dir::Tmpname.make_tmpname("#{dir_path}/result_", nil)

    file = File.open("#{filepath}", "w")
    begin

      file.write(oyente_params[:bytecode].gsub(/^0x/, ""))
    rescue
      @contract[:error] = "Error"
      return
    ensure
      file.close
    end

    begin
      threads <<  Thread.new {
        while (@output.empty?)
          sse.write({ :time => Time.now })
          sleep 1
        end
      }

      threads << Thread.new {
        output = oyente_cmd(file.path, "#{options} -b")
        @output = JSON.parse(output)
        UserMailer.bytecode_analysis_result(file.path, @output, oyente_params[:email]).deliver_later unless oyente_params[:email].nil?
        puts @output.inspect
        sse.write({:contract => @output})
      }
      threads.each &:join
      return render @output
    rescue
      @output[:error] = "Error"
    ensure
      sse.close
    end
  end
end

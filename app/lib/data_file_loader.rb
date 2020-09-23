module DataFileLoader
  mattr_accessor :ymin_log, :ymax_log, :ymin, :ymax, :xymin, :xymax, :data_to_plot

  include ActiveSupport::Concern

  def get_log10iofq_data
    @data_to_plot = ScatterData.new(:cols => [0,1])

    self.open do |tempfile|
      @data_to_plot.file = tempfile
      @data_to_plot.read_contents
      @ymin_log = signif(@data_to_plot.y_min_log,3)
      @ymax_log = signif(@data_to_plot.y_max_log + (@data_to_plot.y_max_log*0.05).abs,3)
      @qvalmax, @ival = @data_to_plot.xy_log_data.last
      return @data_to_plot.xy_log_data, @qvalmax, @ymin_log, @ymax_log
    end
  end


  def get_sec_trace
    @data_to_plot = ScatterData.new

    self.open do |tempfile|
      @data_to_plot.file = tempfile
      @data_to_plot.read_sec_file
      last_index = @data_to_plot.xy_data.last[0]
      return DataToPlot.new(@data_to_plot.xy_data, 0, last_index, @data_to_plot.y_min, signif(@data_to_plot.y_max + (@data_to_plot.y_max*0.01).abs,3))
    end
  end


  def get_all_transformed_data_to_plot
    @data_to_plot = ScatterData.new(:cols => [0,1])

    self.open do |tempfile|
      @data_to_plot.file = tempfile
      @data_to_plot.read_contents

      return DataToPlot.new(@data_to_plot.xy_log_data, 0, @data_to_plot.xy_log_data.last[0], signif(@data_to_plot.y_min_log,3), signif(@data_to_plot.y_max_log + (@data_to_plot.y_max_log*0.05).abs,3)),
          DataToPlot.new(@data_to_plot.logx_logy_data, 0, @data_to_plot.logx_logy_data.last[0], signif(@data_to_plot.y_min_log,3), signif(@data_to_plot.y_max_log + (@data_to_plot.y_max_log*0.05).abs,3)),
          DataToPlot.new(@data_to_plot.kratky_data, 0, @data_to_plot.kratky_data.last[0], signif(@data_to_plot.y_min_log,3), signif(@data_to_plot.y_max_log + (@data_to_plot.y_max_log*0.05).abs,3)),
          DataToPlot.new(@data_to_plot.x_xy_data, 0, @data_to_plot.x_xy_data.last[0], signif(@data_to_plot.xy_min,3), signif(@data_to_plot.xy_max + (@data_to_plot.xy_max*0.05).abs,3))
    end
  end


  private
  def signif(number, signs)
    Float("%.#{signs}g" % number)
  end
end
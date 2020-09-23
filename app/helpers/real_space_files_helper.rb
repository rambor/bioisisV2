module RealSpaceFilesHelper

  def get_real_space_data(real_space_file)
    blob = real_space_file.file
    data_to_plot = PofrData.new(:file_blob => blob)
    data_to_plot.read_contents
    ymin=0
    ymax=0
    blob.open do |tempfile|
      data_to_plot.filename = blob.filename
      data_to_plot.read_contents
      ymin = data_to_plot.pr_min # signif(@data_to_plot.y_min,3)
      ymax = data_to_plot.pr_max
        #ymax = Float(("%.#{3}g" % data_to_plot.pr_max).to_f + (data_to_plot.pr_max*0.01).abs)
    end
    return ymin, ymax, data_to_plot

  end
end

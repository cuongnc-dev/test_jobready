class ExportPdfsController < ApplicationController
  def show
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{t '.export_cart'}_#{Time.current.strftime('%d-%m-%Y')}",
          template: "export_pdfs/show.html.erb",
          disposition: "attachment",
          layout: "export_pdf",
          orientation: "Landscape",
          encoding: "UTF-8"
      end
    end
  end
end

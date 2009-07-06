class SearchesController < ApplicationController
  def new
    @search = Search.new
  end

  def create
    @search = Search.new(params[:search])
    if @search.save
      if @search.events.empty?
        flash[:error] = "Sorry! No results found."
      else
        flash[:notice] = "Successfully submitted search and found #{@search.events.size} results. <%= link_to('Printable Invoice (PDF)', search_path(@search, :format => 'pdf')) %>"
      end
      redirect_to @search
    else
      flash[:notice] = "Something is not right here!"
      render :action => 'new'
    end
  end

  def show
    @search = Search.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf
      format.csv
      format.xml { render :xml => @search.events }
    end
  end
  
  def send_search
    @search = Search.find(params[:search_id])
    render :layout => false
  end

  def send_search_now
    @search = Search.find(params[:search_id])
    @msg = params[:msg]
    @user = current_user

    @emails = []
    @myteam = params[:user_id] ||= []

    @myteam.each do |m|
      @emails << User.find(m).email
    end
    
    spawn do
      Pdf_for_email.make_pdf_for_search(@search)
      ReportMailer.deliver_search_report(@user, @search, @emails, @msg)
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
  
  
end

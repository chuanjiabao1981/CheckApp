#encoding:utf-8
class SessionsController < ApplicationController

  before_filter :check_equipment_status , only:[:zone_supervisor_create,:worker_create]

  def site_admin_new
    render layout:'application_one_column'
  end
  def site_admin_create
    site_admin = SiteAdmin.find_by_name(params[:session][:name])
    if site_admin && site_admin.authenticate(params[:session][:password])
      sign_in(site_admin)
      redirect_to root_path
    else
      flash.now[:error] = '账号或密码错误'
      render 'site_admin_new',layout:'application_one_column'
    end
  end

  def zone_admin_new
    render layout:'application_one_column'
  end

  def zone_admin_create
    zone_admin = ZoneAdmin.find_by_name(params[:session][:name])
    if zone_admin && zone_admin.authenticate(params[:session][:password])
      sign_in(zone_admin)
      redirect_to root_path
    else
      flash.now[:error] = '账号或密码错误'
      render 'zone_admin_new',layout:'application_one_column'
    end
  end

  def checker_new
    render layout:'application_one_column'
  end
  def checker_create
    checker = Checker.find_by_name(params[:session][:name])
    if checker && checker.authenticate(params[:session][:password])
      sign_in(checker)
      redirect_to root_path
    else
      flash.now[:error] = '账号或密码错误'
      render 'checker_new',layout:'application_one_column'
    end
  end
  def worker_new
    respond_to do |format|
      format.mobile
      format.html {render layout:'application_one_column'}
    end
  end

  def worker_create
    worker = Worker.find_by_name(params[:session][:name])
    if worker && worker.authenticate(params[:session][:password])
      sign_in(worker)
      respond_to do |format|
        format.mobile { return redirect_to root_path(format: :mobile)}
        format.html   { return redirect_to root_path}       
        format.json   { return render json:login_success_json(worker)}
      end
    else
      flash.now[:error] = I18n.t 'errors.session.login_fail'
      respond_to do |format|
        format.mobile   {render 'worker_new'}
        format.html     {render 'worker_new',layout:'application_one_column'}
        format.json     {return render json:login_fail_json}
      end
    end
  end

  def zone_supervisor_new
    respond_to do |format|
      format.mobile
      format.html { render layout:'application_one_column'}
    end
  end
  def zone_supervisor_create
    zone_supervisor = ZoneSupervisor.find_by_name(params[:session][:name])
    if zone_supervisor and zone_supervisor.authenticate(params[:session][:password])
      sign_in(zone_supervisor)
      respond_to do |format|
        format.mobile { return redirect_to root_path(format: :mobile)}
        format.html   { return redirect_to root_path}
        format.json   { return render json:login_success_json(zone_supervisor)}
      end
    else
      flash.now[:error] = I18n.t 'errors.session.login_fail'
      respond_to do |format|
        format.mobile {render 'zone_supervisor_new'}
        format.html   {render 'zone_supervisor_new',layout:'application_one_column'}
        format.json   {return render json:login_fail_json}
      end
    end
  end

  def destroy
    sign_out
    respond_to do |format|
      format.mobile {return redirect_to root_path(format: :mobile) }
      format.html   {return redirect_to root_path}
    end
  end
end

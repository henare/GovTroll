class AuthenticationsController < ApplicationController
  before_action :set_authentication, only: [:show, :edit, :update, :destroy]

  def home
  end

  # GET /authentications
  # GET /authentications.json
  def index
    @authentications = Authentication.all
  end

  def twitter
    raise omni = request.env["omniauth.auth"].to_yaml
    authentication = Authentication.find_by_provider_and_uid(omni['provider'], omni['uid'])

    if authentication

      flash[:notice] = "Logged in Successfully"
      sign_in_and_redirect User.find(authentication.user_id)

    elsif current_user
      token = omni['credentials'].token
      token_secret = omni['credentials'].secret

      current_user.authentications.create!(provider:omni['provider'], uid:omni['uid'], token:token, token_secret:token_secret)
      flash[:notice] = "Authentication successful."
      sign_in_and_redirect current_user

    else
      user = User.new(email:"#{rand(10000).to_s(16)}@govtroll.com", password:"rand(10000).to_s(16)")
      user.apply_omniauth(omni)
      if user.save
      flash[:notice] = "Logged in."
      sign_in_and_redirect User.find(user.id)
      else
      session[:omniauth] = omni.except('extra')
      redirect_to new_user_registration_path
      end
       end
    end
  end

  def facebook
    raise omni = request.env["omniauth.auth"].to_yaml
    authentication = Authentication.find_by_provider_and_uid(omni['provider'], omni['uid'])
  end

  # GET /authentications/1
  # GET /authentications/1.json
  def show
  end

  # GET /authentications/new
  def new
    @authentication = Authentication.new
  end

  # GET /authentications/1/edit
  def edit
  end

  # POST /authentications
  # POST /authentications.json
  def create
    @authentication = Authentication.new(authentication_params)

    respond_to do |format|
      if @authentication.save
        format.html { redirect_to @authentication, notice: 'Authentication was successfully created.' }
        format.json { render :show, status: :created, location: @authentication }
      else
        format.html { render :new }
        format.json { render json: @authentication.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /authentications/1
  # PATCH/PUT /authentications/1.json
  def update
    respond_to do |format|
      if @authentication.update(authentication_params)
        format.html { redirect_to @authentication, notice: 'Authentication was successfully updated.' }
        format.json { render :show, status: :ok, location: @authentication }
      else
        format.html { render :edit }
        format.json { render json: @authentication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authentications/1
  # DELETE /authentications/1.json
  def destroy
    @authentication.destroy
    respond_to do |format|
      format.html { redirect_to authentications_url, notice: 'Authentication was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_authentication
      @authentication = Authentication.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def authentication_params
      params.require(:authentication).permit(:user_id, :provider, :uid, :index, :create, :destroy)
    end
end

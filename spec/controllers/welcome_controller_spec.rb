require "spec_helper"

describe WelcomeController do
  describe "index" do
    it "renders" do
      get :index
      expect(response.status).to eq(200)
      expect(response).to render_template("index")
      expect(response).to render_with_layout("application_revised")
      expect(flash).to_not be_present
    end
    context "json request format" do
      it "renders revised_layout (ignoring response format)" do
        get :index, format: :json
        expect(response.status).to eq(200)
        expect(response).to render_template("index")
        expect(response).to render_with_layout("application_revised")
        expect(flash).to_not be_present
      end
    end
  end

  describe "bike_creation_graph" do
    it "renders embed without xframe block" do
      get :bike_creation_graph
      expect(response.code).to eq("200")
      expect(response.headers["X-Frame-Options"]).not_to be_present
    end
  end

  describe "goodbye" do
    it "renders" do
      get :goodbye
      expect(response.status).to eq(200)
      expect(response).to render_template("goodbye")
      expect(response).to render_with_layout("application_revised")
      expect(flash).to_not be_present
    end
    context "logged_in" do
      include_context :logged_in_as_user
      it "redirects" do
        get :goodbye
        expect(response).to redirect_to logout_url
      end
      context "unconfirmed user" do
        let(:user) { FactoryBot.create(:user) }
        it "redirects" do
          get :goodbye
          expect(response).to redirect_to logout_url
        end
      end
    end
  end

  describe "choose registration" do
    context "user not present" do
      it "redirects" do
        get :choose_registration
        expect(response).to redirect_to(new_user_url)
      end
    end
    context "user present" do
      it "renders" do
        user = FactoryBot.create(:user_confirmed)
        set_current_user(user)
        get :choose_registration
        expect(response.status).to eq(200)
        expect(response).to render_template("choose_registration")
        expect(response).to render_with_layout("application_revised")
      end
    end
  end

  describe "user_home" do
    context "user not logged in" do
      it "redirects" do
        get :user_home
        expect(response).to redirect_to(new_user_url)
      end
    end

    context "user logged in" do
      before { set_current_user(user) }

      context "unconfirmed" do
        let(:user) { FactoryBot.create(:user) }
        it "redirects" do
          get :user_home
          expect(flash).to_not be_present
          expect(response).to redirect_to(please_confirm_email_users_path)
        end
      end

      context "confirmed" do
        let(:user) { FactoryBot.create(:user_confirmed) }
        context "without anything" do
          it "renders" do
            get :user_home
            expect(response.status).to eq(200)
            expect(response).to render_template("user_home")
            expect(response).to render_with_layout("application_revised")
            expect(session[:current_organization_id]).to eq "0"
            expect(assigns[:current_organization]).to be_nil
          end
        end
        context "with organization" do
          let(:organization) { FactoryBot.create(:organization) }
          let(:user) { FactoryBot.create(:organization_member, organization: organization) }
          it "sets current_organization_id" do
            get :user_home
            expect(response.status).to eq(200)
            expect(response).to render_template("user_home")
            expect(response).to render_with_layout("application_revised")
            expect(session[:current_organization_id]).to eq organization.id
            expect(assigns[:current_organization]).to eq organization
          end
        end
        context "with stuff" do
          let(:ownership) { FactoryBot.create(:ownership, user_id: user.id, current: true) }
          let(:bike) { ownership.bike }
          let(:bike_2) { FactoryBot.create(:bike) }
          let(:lock) { FactoryBot.create(:lock, user: user) }
          let(:organization) { FactoryBot.create(:organization) }
          before do
            allow_any_instance_of(User).to receive(:bikes) { [bike, bike_2] }
            allow_any_instance_of(User).to receive(:locks) { [lock] }
          end
          it "renders and user things are assigned" do
            session[:current_organization_id] = organization.id # Even though the user isn't part of the organization, permit it
            get :user_home, per_page: 1
            expect(response.status).to eq(200)
            expect(response).to render_template("user_home")
            expect(response).to render_with_layout("application_revised")
            expect(assigns(:bikes).count).to eq 1
            expect(assigns(:per_page).to_s).to eq "1"
            expect(assigns(:bikes).first).to eq(bike)
            expect(assigns(:locks).first).to eq(lock)
            expect(session[:current_organization_id]).to eq organization.id
            expect(assigns[:current_organization]).to eq organization
          end
        end
      end
    end
  end
end

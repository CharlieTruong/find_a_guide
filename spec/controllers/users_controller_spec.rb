require_relative '../spec_helper'
include OmniauthMacros

describe UsersController do

  describe 'Routing & Rendering' do

    # describe 'GET#Index' do
    #   it 'should render user index template' do
    #     get :index
    #     expect(response).to render_template :index
    #   end
    # end

    describe 'GET#Dashboard' do
      it 'should render user dashboard template' do
        user = FactoryGirl.create(:user)
        login_user(user.id)

        get :dashboard
        expect(response).to render_template :dashboard
      end
    end

    describe 'GET#Edit' do
      it 'should render user edit template' do
        user = FactoryGirl.create(:user)
        login_user(user.id)

        get :edit, {id: user.id}
        expect(response).to render_template :edit
      end
    end

    describe 'GET#Show' do
      it 'should render user show template' do
        user = FactoryGirl.create(:user)
        login_user(user.id)

        get :show, {id: user.id}
        expect(response).to render_template :show
      end
    end

  end #End Routing and Rendering

  describe 'Object Population' do

    describe 'users#ambassador_toggle' do
      it 'should change the is_ambassador attribute' do
        pending
      end

    end

    describe 'users#ambassador_availability_toggle' do
      it 'should change the ambassador_availability' do
        pending
      end
    end

  end # End Object Population

end # End UsersController describe

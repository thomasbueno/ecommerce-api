require 'rails_helper'

RSpec.describe "Admin::V1::Users as :admin", type: :request do
  let!(:user) { create(:user) }

  context "GET /users" do
    let(:url) { "/admin/v1/users" }
    let!(:users) { create_list(:user, 5) }

    it "returns all users" do
      get url, headers: auth_header(user)
      expect(body_json['users']).to contain_exactly *users.push(user).as_json
    end

    it "return success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "POST /users" do
    let(:url) { "/admin/v1/users" }

    context "with valid params" do
      let(:user_params) { {user: attributes_for(:user)}.to_json }

      it "adds a new user" do
        expect do
          post url, headers: auth_header(user), params: user_params
        end.to change(User, :count).by(1)
      end

      it "returns last added user" do
        post url, headers: auth_header(user), params: user_params
        expected_user = User.last.as_json(only: %i(id name email profile))
        expect(body_json['user']).to eq expected_user
      end

      it "return success status" do
        post url, headers: auth_header(user), params: user_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:user_invalid_params) do
        { user: attributes_for(:user, name: nil) }.to_json
      end

      it "doesn't add a new user" do
        expect do
        post url, headers: auth_header(user), params: user_invalid_params
        end.to_not change(User, :count)
      end

      it "returns error messages" do
        post url, headers: auth_header(user), params: user_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it "returns unprocessable_entity status" do
        post url, headers: auth_header(user), params: user_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "PATCH /users/:id" do
    let(:user) { create(:user) }
    let(:url) { "/admin/v1/users/#{user.id}" }

    context "with valid params" do
      let(:new_name) { "My new user" }
      let(:user_params) { {user: {name: new_name}}.to_json }

      it "updates user" do
        patch url, headers: auth_header(user), params: user_params
        user.reload

        expected_user = user.as_json(only: %i(id name email profile))
        expect(body_json['user']).to eq expected_user
      end

      it "return success status" do
        patch url, headers: auth_header(user), params: user_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:user_invalid_params) do
        { user: attributes_for(:user, name: nil) }.to_json
      end

      it "doesn't update user" do
        old_name = user.name
        patch url, headers: auth_header(user), params: user_invalid_params
        user.reload
        expect(user.name).to eq old_name
      end

      it "returns error messages" do
        patch url, headers: auth_header(user), params: user_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it "returns unprocessable_entity status" do
        patch url, headers: auth_header(user), params: user_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "DELETE /users/:id" do
    let!(:delete_user) { create(:user) }
    let(:url) { "/admin/v1/users/#{delete_user.id}" }

    it "removes user" do
      expect do
        delete url, headers: auth_header(user)  
      end.to change(User, :count).by(-1)
    end

    it "return no_content status" do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it "doesn't return any body content" do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end
  end
end
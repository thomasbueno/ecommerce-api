require 'rails_helper'

RSpec.describe "Admin::V1::SystemRequirements as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    let!(:system_requirements) { create_list(:system_requirement, 10) }

    context "without any params" do
      it "returns 10 system requirements" do
        get url, headers: auth_header(user)
        expect(body_json['system_requirements'].count).to eq 10
      end

      it "returns 10 first system requirements" do
        get url, headers: auth_header(user)
        expected_system_requirements = system_requirements[0..9].as_json
        expect(body_json['system_requirements']).to contain_exactly *expected_system_requirements
      end

      it "return success status" do
        get url, headers: auth_header(user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "with search[name] param" do
      let!(:search_name_system_requirements) do
        system_requirements = []
        15.times { |n| system_requirements << create(:system_requirement, name: "Search #{n + 1}") }
        system_requirements
      end

      let(:search_params) { {search: {name: "Search"}} }

      it "returns only searched system requirements limited by default pagination" do
        get url, headers: auth_header(user), params: search_params

        expected_system_requirements = search_name_system_requirements[0..9].map do |system_requirement|
          system_requirement.as_json
        end

        expect(body_json['system_requirements']).to contain_exactly *expected_system_requirements
      end

      it "return success status" do
        get url, headers: auth_header(user), params: search_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with pagination params" do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { {page: page, length: length} }

      it "returns records sized by :length" do
        get url, headers: auth_header(user), params: pagination_params
        expect(body_json['system_requirements'].count).to eq length
      end

      it "returns system requirements limited by pagination" do
        get url, headers: auth_header(user), params: pagination_params
        expected_system_requirements = system_requirements[5..9].as_json
        expect(body_json['system_requirements']).to contain_exactly *expected_system_requirements
      end

      it "return success status" do
        get url, headers: auth_header(user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with order params" do
      let(:order_params) { { order: {name: 'desc'} } }

      it "returns ordered system requirements limited by default pagination" do
        get url, headers: auth_header(user), params: order_params
        system_requirements.sort! { |a, b| b[:name] <=> a[:name] }
        expected_system_requirements = system_requirements[0..9].as_json
        expect(body_json['system_requirements']).to contain_exactly *expected_system_requirements
      end

      it "return success status" do
        get url, headers: auth_header(user), params: order_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "POST /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }

    context "with valid params" do
      let(:system_requirement_params) { { system_requirement: attributes_for(:system_requirement) }.to_json }

      it "adds a new system requirement" do
        expect do
          post url, headers: auth_header(user), params: system_requirement_params
        end.to change(SystemRequirement, :count).by(1)
      end

      it "returns last added system requirement" do
        post url, headers: auth_header(user), params: system_requirement_params
        expect_system_requirement = SystemRequirement.last.as_json(only: %i(id name operational_system storage processor memory video_board))
        expect(body_json['system_requirement']).to eq expect_system_requirement
      end

      it "returns success status" do
        post url, headers: auth_header(user), params: system_requirement_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:system_requirement_invalid_params) do
        { system_requirement: attributes_for(:system_requirement, name: nil) }.to_json
      end

      it "doesn't add a new system requirement" do
        expect do
          post url, headers: auth_header(user), params: system_requirement_invalid_params
        end.to_not change(SystemRequirement, :count)
      end

      it "returns error messages" do
        post url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it "returns unprocessable_entity status" do
        post url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "GET /system_requirements/:id" do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    it "returns requested category" do
      get url, headers: auth_header(user)
      expected_system_requirement = system_requirement.as_json(only: %i(id name operational_system storage processor memory video_board))
      expect(body_json['system_requirement']).to eq expected_system_requirement
    end

    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "PATCH /system_requirements/:id" do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    context "with valid params" do
      let(:new_name) { "My new system requirement" }
      let(:system_requirement_params) { {system_requirement: {name: new_name}}.to_json }

      it "updates system requirement" do
        patch url, headers: auth_header(user), params: system_requirement_params
        system_requirement.reload

        expected_system_requirement = system_requirement.as_json(only: %i(id name operational_system storage processor memory video_board))
        expect(body_json['system_requirement']).to eq expected_system_requirement
      end

      it "return success status" do
        patch url, headers: auth_header(user), params: system_requirement_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:system_requirement_invalid_params) do
        { system_requirement: attributes_for(:system_requirement, name: nil) }.to_json
      end

      it "doesn't update system requirement" do
        old_name = system_requirement.name
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        system_requirement.reload
        expect(system_requirement.name).to eq old_name
      end

      it "returns error messages" do
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it "returns unprocessable entity status" do
        patch url, headers: auth_header(user), params: system_requirement_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "DELETE /system_requirements/:id" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    it "removes system requirement" do
      expect do
        delete url, headers: auth_header(user)
      end.to change(SystemRequirement, :count).by(-1)
    end

    it "return no_content status" do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it "doesn't return any body content" do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end

    it "removes all games associated with system requirements" do
      create_list(:game, 3, system_requirement: system_requirement)
      delete url, headers: auth_header(user)
      expect(body_json['errors']['fields']).to have_key('base')
    end
  end
end

require 'rails_helper'

RSpec.describe "Api::V1::Tasks::Archives", type: :request do
  describe 'GET /api/v1/tasks/archived' do
    let!(:_archived_tasks) { create_list(:task, 2, archived: true) }
    let!(:_unarchived_task) { create(:task, archived: false) }

    it 'タスクのリストを返す' do
      get archived_api_v1_tasks_path
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['tasks'].size).to eq(2)
    end
  end

  describe 'POST /api/v1/tasks/:id/archive' do
    let!(:task1) { create(:task, status: :todo, position: 1) }
    let!(:task2) { create(:task, status: :todo, position: 2) }
    let!(:task3) { create(:task, status: :todo, position: 3) }

    subject { patch api_v1_task_archive_path(task1) }

    context 'タスクが存在する場合' do
      it 'タスクをアーカイブする' do
        subject
        task1.reload
        expect(task1.archived).to be_truthy
      end

      it '200を返す' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'アーカイブ後、positionを更新する' do
        subject
        task2.reload
        task3.reload
        expect(task2.position).to eq(1)
        expect(task3.position).to eq(2)
      end
    end

    context 'タスクが存在しない場合' do
      it '404を返す' do
        patch '/api/v1/tasks/999/archive'
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

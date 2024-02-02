require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket = tickets(:one)
  end

  test "should get index" do
    get tickets_url, as: :json
    assert_response :success
  end

  test "should create ticket" do
    assert_difference("Ticket.count") do
      post tickets_url, params: { ticket: { assigned_user_id: @ticket.assigned_user_id, description: @ticket.description, due_date: @ticket.due_date, progress: @ticket.progress, ticket_status_id: @ticket.ticket_status_id, title: @ticket.title } }, as: :json
    end

    assert_response :created
  end

  test "should show ticket" do
    get ticket_url(@ticket), as: :json
    assert_response :success
  end

  test "should update ticket" do
    patch ticket_url(@ticket), params: { ticket: { assigned_user_id: @ticket.assigned_user_id, description: @ticket.description, due_date: @ticket.due_date, progress: @ticket.progress, ticket_status_id: @ticket.ticket_status_id, title: @ticket.title } }, as: :json
    assert_response :success
  end

  test "should destroy ticket" do
    assert_difference("Ticket.count", -1) do
      delete ticket_url(@ticket), as: :json
    end

    assert_response :no_content
  end
end

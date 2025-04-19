shared_context 'devise user login', shared_context: :metadata do
  before do
    sign_in(user)
  end
end

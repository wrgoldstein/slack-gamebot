require 'spec_helper'

describe SlackGamebot::Commands::Reset, vcr: { cassette_name: 'user_info' } do
  it 'requires a secret' do
    expect(::User).to_not receive(:reset_all!)
    expect(message: 'gamebot reset').to respond_with_error('Missing secret.')
  end
  it 'requires a valid secret' do
    expect(::User).to_not receive(:reset_all!)
    expect(message: 'gamebot reset invalid').to respond_with_error('Invalid secret.')
  end
  it 'resets with the correct secret' do
    expect(::User).to receive(:reset_all!).once
    expect(message: "gamebot reset #{ENV['GAMEBOT_SECRET']}").to respond_with_slack_message('Welcome to the new season!')
  end
  it 'cancels open challenges' do
    proposed_challenge = Fabricate(:challenge, state: ChallengeState::PROPOSED)

    accepted_challenge = Fabricate(:challenge, state: ChallengeState::PROPOSED)
    accepted_challenge.accept!(accepted_challenge.challenged.first)

    expect(message: "gamebot reset #{ENV['GAMEBOT_SECRET']}").to respond_with_slack_message('Welcome to the new season!')

    expect(proposed_challenge.reload.state).to eq ChallengeState::CANCELED
    expect(accepted_challenge.reload.state).to eq ChallengeState::CANCELED
  end
  it 'resets user stats' do
    user = Fabricate(:user, elo: 48, losses: 1, wins: 2, tau: 0.5)
    expect(message: "gamebot reset #{ENV['GAMEBOT_SECRET']}").to respond_with_slack_message('Welcome to the new season!')
    user.reload
    expect(user.wins).to eq 0
    expect(user.losses).to eq 0
    expect(user.tau).to eq 0
    expect(user.elo).to eq 0
  end
end

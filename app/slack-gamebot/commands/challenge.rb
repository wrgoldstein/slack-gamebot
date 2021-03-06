module SlackGamebot
  module Commands
    class Challenge < Base
      def self.call(data, _command, arguments)
        challenger = ::User.find_create_or_update_by_slack_id!(data.user)
        challenge = ::Challenge.create_from_teammates_and_opponents!(data.channel, challenger, arguments)
        send_message_with_gif data.channel, "#{challenge.challengers.map(&:user_name).join(' and ')} challenged #{challenge.challenged.map(&:user_name).join(' and ')} to a match!", 'challenge'
      end
    end
  end
end

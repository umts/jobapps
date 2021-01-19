# frozen_string_literal: true

# Expects that the controller action called after this is invoked
# will call show_message with the symbol given, and a hash
# containing a default.
def expect_flash_message(name)
  expect_any_instance_of(ConfigurableMessages)
    .to receive(:show_message)
    .with(name, hash_including(:default))
end

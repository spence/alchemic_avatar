defmodule AlchemicAvatar do
  @moduledoc """
  `AlchemicAvatar.generate` - generate avatar
  """

  @font_filename Path.join(__DIR__, "data/Roboto-Medium")

  @doc """
  ## Examples
      AlchemicAvatar.generate 'ksz2k'
  """
  def generate_binary(username) do
    identity = identity(username)
    size = AlchemicAvatar.Config.size()
    generate_file_binary(identity, size)
  end

  defp identity(<<char, _rest::binary>> = username) do
    color = AlchemicAvatar.Color.from_name(username)
    letter = <<char>>
    %{color: color, letter: letter}
  end

  defp generate_file_binary(identity, size) do
    System.cmd("convert", [
      "-size", "#{size}x#{size}",
      "xc:#{to_rgb(identity.color)}",
      "-pointsize", AlchemicAvatar.Config.font_size(),
      "-font", "#{@font_filename}",
      "-weight", "#{AlchemicAvatar.Config.weight()}",
      "-fill", AlchemicAvatar.Config.fill_color(),
      "-gravity", "Center",
      "-annotate", "#{AlchemicAvatar.Config.annotate_position()}", "#{identity.letter}",
      "png:-"
    ])
  end

  defp to_rgb(color) do
    [r, g, b ] = color
    "rgb(#{r},#{g},#{b})"
  end
end

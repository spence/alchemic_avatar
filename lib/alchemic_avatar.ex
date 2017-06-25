defmodule AlchemicAvatar do
  @moduledoc """
  `AlchemicAvatar.generate` - generate avatar
  """

  @font_filename Path.join(__DIR__, "data/Roboto-Medium")

  @doc """
  ## Examples
      AlchemicAvatar.generate 'ksz2k'
      AlchemicAvatar.generate 'ksz2k', cache: false
  if set cache to false, it will generate avatar whenever file exist or not
  """
  def generate(username, opts \\ []) do
    cache = Keyword.get(opts, :cache, true)
    identity = identity(username)
    size = AlchemicAvatar.Config.size()
    do_generate(identity, size, cache)
  end

  defp do_generate(identity, size, use_cache) do
    filename = filename(identity, size)

    if use_cache and File.exists?(filename) do
      filename
    else
      convert_file(identity, filename, size)
    end
  end

  defp identity(<<char, _rest::binary>> = username) do
    color = AlchemicAvatar.Color.from_name(username)
    letter = <<char>>
    %{color: color, letter: letter}
  end

  defp cache_path do
    "#{AlchemicAvatar.Config.cache_base_path()}/alchemic_avatar"
  end

  defp dir_path(identity) do
    path = "#{cache_path()}/#{identity.letter}/#{identity.color |> Enum.join("_")}"
    :code.priv_dir(AlchemicAvatar.Config.app_name()) |> Path.join(path)
  end

  defp filename(identity, size) do
    "#{dir_path(identity)}/#{size}.png"
  end

  defp mk_path(path) do
    unless File.exists?(path) do
      File.mkdir_p path
    end
    :ok
  end

  defp convert_file(identity, filename, size) do
    mk_path dir_path(identity)
    System.cmd "convert", [
      "-size", "#{size}x#{size}",
      "xc:#{to_rgb(identity.color)}",
      "-pointsize", AlchemicAvatar.Config.font_size(),
      "-font", "#{@font_filename}",
      "-weight", "#{AlchemicAvatar.Config.weight()}",
      "-fill", AlchemicAvatar.Config.fill_color(),
      "-gravity", "Center",
      "-annotate", "#{AlchemicAvatar.Config.annotate_position()}", "#{identity.letter}",
      "#{filename}"
    ]
    filename
  end

  defp to_rgb(color) do
    [r, g, b ] = color
    "rgb(#{r},#{g},#{b})"
  end
end

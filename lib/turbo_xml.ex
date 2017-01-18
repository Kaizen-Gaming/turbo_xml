defmodule TurboXml do
  @moduledoc false

  defmacro doc(do: body) do
    quote do
      ["<?xml version=\"1.0\"?>", unquote(body)]
    end
  end

  defmacro node(name, do: body) do
    node_inner(name, [], body)
  end

  defmacro node(name, attrs, do: body) do
    node_inner(name, attrs, body)
  end

  def write_node_attrs([]), do: []
  def write_node_attrs([{key, val} | rest]), do: [] # TODO pattern match key and val, recurse on rest

  def write_node_body(nil), do: []
  def write_node_body(body) when is_binary(body), do: string_escape(body)
  def write_node_body(body), do: body

  defp node_inner(name, attrs, body) do
    quote do
      name = TurboXml.normalize_name(unquote(name))
      ["<", name, ">", TurboXml.write_node_body(unquote(body)), "</", name, ">"]
    end
  end

  def normalize_name(name) when is_binary(name), do: name
  def normalize_name(name) when is_atom(name), do: Atom.to_string(name)

  # http://stackoverflow.com/questions/1091945/what-characters-do-i-need-to-escape-in-xml-documents
  defp string_escape("\"" <> rest), do: ["&quot;" | string_escape(rest)]
  defp string_escape("'" <> rest), do: ["&apos;" | string_escape(rest)]
  defp string_escape("<" <> rest), do: ["&lt;" | string_escape(rest)]
  defp string_escape(">" <> rest), do: ["&gt;" | string_escape(rest)]
  defp string_escape("&" <> rest), do: ["&amp;" | string_escape(rest)]
  defp string_escape(<<other :: utf8, rest :: binary>>), do: [other | string_escape(rest)]
  defp string_escape(""), do: []

end

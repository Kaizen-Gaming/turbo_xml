defmodule TurboXml do
  @moduledoc false
  
  defmacro doc(do: body) do
    quote do
      ["<?xml version=\"1.0\"?>", unquote(body)]
    end
  end

  defmacro ele(name, attrs \\ [])
  defmacro ele(name, do: body), do: ele_inner(name, [], body)
  defmacro ele(name, attrs), do: ele_inner(name, attrs, :self_closing)
  defmacro ele(name, attrs, do: body), do: ele_inner(name, attrs, body)
  
  def write_ele_attrs([]), do: []
  def write_ele_attrs([{key, val} | rest]) do
    [" ", normalize_name(key), "=\"", val |> to_string() |> string_escape(), "\"" | write_ele_attrs(rest)]
  end

  def write_ele_body(nil), do: []
  def write_ele_body(body) when is_binary(body), do: string_escape(body)
  def write_ele_body(body), do: body

  defp ele_inner(name, attrs, body) do
    quote do
      name = TurboXml.normalize_name(unquote(name))
        |> TurboXml.validate_tag_prefix()
        |> TurboXml.validate_tag()
      pass_attrs = TurboXml.write_ele_attrs(unquote(attrs))
      body_passed = unquote(body)
      body_actual =
        case body_passed do
          :self_closing -> "/>"
          _ -> [">", TurboXml.write_ele_body(body_passed), "</", name, ">"]
        end
      ["<", name, pass_attrs, body_actual]
    end
  end

  def normalize_name(name) when is_binary(name), do: name
  def normalize_name(name) when is_atom(name), do: Atom.to_string(name)

  def validate_tag_prefix(<<x :: utf8, m :: utf8, l :: utf8, _rest :: binary>>)
  when x in [?x, ?X] and m in [?m, ?M] and l in [?l, ?L]
  do
    raise "Element names cannot start with the letters xml (or XML, or Xml, etc)."
  end
  def validate_tag_prefix(<<l :: utf8, _rest :: binary>>)
  when l != ?_ and not (l in ?a..?z) and not (l in ?A..?Z)
  do
    raise "Element names must start with a letter or underscore."
  end
  def validate_tag_prefix(name), do: name

  def validate_tag(<<l :: utf8, _rest :: binary>>)
  when not (l in [?_, ?-, ?., ?:]) and not (l in ?a..?z) and not (l in ?A..?Z) and not (l in ?0..?9)
  do
    raise "Element names can contain letters, digits, hyphens, underscores, and periods."
  end
  def validate_tag(<<l :: utf8, rest :: binary>>), do: [l | validate_tag(rest)]
  def validate_tag(""), do: []

  # http://stackoverflow.com/questions/1091945/what-characters-do-i-need-to-escape-in-xml-documents
  defp string_escape("\"" <> rest), do: ["&quot;" | string_escape(rest)]
  defp string_escape("'" <> rest), do: ["&apos;" | string_escape(rest)]
  defp string_escape("<" <> rest), do: ["&lt;" | string_escape(rest)]
  defp string_escape(">" <> rest), do: ["&gt;" | string_escape(rest)]
  defp string_escape("&" <> rest), do: ["&amp;" | string_escape(rest)]
  defp string_escape(<<other :: utf8, rest :: binary>>), do: [other | string_escape(rest)]
  defp string_escape(""), do: []
end

defmodule TurboXmlTest do
  use ExUnit.Case, async: true
  doctest TurboXml
  import TurboXml

  test "turbo xml" do
    xml = doc do
      node "n1" do
        "text1"
      end
    end
    assert :erlang.iolist_to_binary(xml) === "<?xml version=\"1.0\"?><n1>text1</n1>"
  end

  test "dynamic turbo xml" do
    xml = doc do
      node "root" do
        for x <- 1..3 do
          node "n#{x}" do
            "t#{x}"
          end
        end
      end
    end
    assert :erlang.iolist_to_binary(xml) ===
      "<?xml version=\"1.0\"?><root><n1>t1</n1><n2>t2</n2><n3>t3</n3></root>"
  end

  test "node body nil handling" do
    xml = doc do
      node "nilTest" do end
    end
    xml_bin = :erlang.iolist_to_binary(xml)
    assert xml_bin === "<?xml version=\"1.0\"?><nilTest></nilTest>"
  end

  test "self closing tag" do
    xml_bin = TurboXml.node("self_closing") |> IO.iodata_to_binary()
    assert xml_bin === "<self_closing/>"
  end

  test "self closing tag with attributes" do
    xml_bin = TurboXml.node("self_closing", id: "tag") |> IO.iodata_to_binary()
    assert xml_bin === "<self_closing id=\"tag\"/>"
  end

  test "bad xml" do
    xml = node "bad" do
      "<iambad&&\"yo'>"
    end
    xml_bin = :erlang.iolist_to_binary(xml)
    assert xml_bin === "<bad>&lt;iambad&amp;&amp;&quot;yo&apos;&gt;</bad>"
  end

  test "atom node name" do
    xml = node :node do end
    xml_bin = :erlang.iolist_to_binary(xml)
    assert xml_bin === "<node></node>"
  end

  test "xml attributes" do
    xml = node "node", id: "me!", class: "ftou" do  end
    xml_bin = :erlang.iolist_to_binary(xml)
    assert xml_bin === "<node id=\"me!\" class=\"ftou\"></node>"
  end

  test "xml not valid name" do
    assert_raise RuntimeError, fn ->
      node "xml" do  end
    end
    assert_raise RuntimeError, fn ->
      node "2xml" do  end
    end
    assert_raise RuntimeError, fn ->
      node "john kennedy" do  end
    end
  end

  test "xml handle integer" do
    xml_bin = node "int_number", int: 1 do end
      |> :erlang.iolist_to_binary()
    assert xml_bin === "<int_number int=\"1\"></int_number>"
  end

  test "xml handle decimal" do
    xml_bin = node "dec_number", dec: 10.5 do end
     |> :erlang.iolist_to_binary()
    assert xml_bin === "<dec_number dec=\"10.5\"></dec_number>"
  end

  test "xml valid name1", do: (node "axml" do end)
  test "xml valid name2", do: (node "_xml" do end)
  test "xml valid name3", do: (node "_1" do end)

end

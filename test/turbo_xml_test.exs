defmodule TurboXmlTest do
  use ExUnit.Case, async: true
  doctest TurboXml
  import TurboXml

  test "turbo xml" do
    xml = doc do
      ele "n1" do
        "text1"
      end
    end
    assert IO.iodata_to_binary(xml) === "<?xml version=\"1.0\"?><n1>text1</n1>"
  end

  test "dynamic turbo xml" do
    xml = doc do
      ele "root" do
        for x <- 1..3 do
          ele "n#{x}" do
            "t#{x}"
          end
        end
      end
    end
    assert IO.iodata_to_binary(xml) ===
      "<?xml version=\"1.0\"?><root><n1>t1</n1><n2>t2</n2><n3>t3</n3></root>"
  end

  test "node body nil handling" do
    xml = doc do
      ele "nilTest" do end
    end
    xml_bin = IO.iodata_to_binary(xml)
    assert xml_bin === "<?xml version=\"1.0\"?><nilTest></nilTest>"
  end

  test "self closing tag" do
    xml_bin = ele("self_closing") |> IO.iodata_to_binary()
    assert xml_bin === "<self_closing/>"
  end

  test "self closing tag with attributes" do
    xml_bin = ele("self_closing", id: "tag") |> IO.iodata_to_binary()
    assert xml_bin === "<self_closing id=\"tag\"/>"
  end

  test "bad xml" do
    xml = ele "bad" do
      "<iambad&&\"yo'>"
    end
    xml_bin = IO.iodata_to_binary(xml)
    assert xml_bin === "<bad>&lt;iambad&amp;&amp;&quot;yo&apos;&gt;</bad>"
  end

  test "atom node name" do
    xml = ele :ele do end
    xml_bin = IO.iodata_to_binary(xml)
    assert xml_bin === "<ele></ele>"
  end

  test "xml attributes" do
    xml = ele "ele", id: "me!", class: "ftou" do  end
    xml_bin = IO.iodata_to_binary(xml)
    assert xml_bin === "<ele id=\"me!\" class=\"ftou\"></ele>"
  end

  test "xml not valid name" do
    assert_raise RuntimeError, fn ->
      ele "xml" do  end
    end
    assert_raise RuntimeError, fn ->
      ele "2xml" do  end
    end
    assert_raise RuntimeError, fn ->
      ele "John Kennedy" do  end
    end
  end

  test "xml handle integer" do
    xml_bin = ele "int_number", int: 1 do end
      |> IO.iodata_to_binary()
    assert xml_bin === "<int_number int=\"1\"></int_number>"
  end

  test "xml handle decimal" do
    xml_bin = ele "dec_number", dec: 10.5 do end
     |> IO.iodata_to_binary()
    assert xml_bin === "<dec_number dec=\"10.5\"></dec_number>"
  end

  test "xml valid name1", do: (ele "axml" do end)
  test "xml valid name2", do: (ele "_xml" do end)
  test "xml valid name3", do: (ele "_1" do end)

end

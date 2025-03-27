defmodule ClickhouseMetrics.ClickTest do
  use ClickhouseMetrics.DataCase, async: true
  alias ClickhouseMetrics.Click

  describe "changeset/2" do
    @valid_attrs %{
      ip: "192.168.1.1",
      user_agent: "Mozilla/5.0",
      browser: "Chrome",
      device: "Desktop"
    }

    test "valid changeset with correct attributes" do
      changeset = Click.changeset(%Click{}, @valid_attrs)
      assert changeset.valid?
    end

    test "invalid changeset without required fields" do
      invalid_attrs = %{}
      changeset = Click.changeset(%Click{}, invalid_attrs)

      refute changeset.valid?
      assert errors_on(changeset) == %{
               ip: ["can't be blank"],
               user_agent: ["can't be blank"],
               browser: ["can't be blank"],
               device: ["can't be blank"]
             }
    end

    test "invalid changeset with empty strings" do
      invalid_attrs = %{ip: "", user_agent: "", browser: "", device: ""}
      changeset = Click.changeset(%Click{}, invalid_attrs)

      refute changeset.valid?
      assert errors_on(changeset) == %{
               ip: ["can't be blank"],
               user_agent: ["can't be blank"],
               browser: ["can't be blank"],
               device: ["can't be blank"]
             }
    end

    test "invalid changeset with missing some fields" do
      invalid_attrs = %{ip: "192.168.1.1", user_agent: "Mozilla/5.0"}
      changeset = Click.changeset(%Click{}, invalid_attrs)

      refute changeset.valid?
      assert errors_on(changeset) == %{
               browser: ["can't be blank"],
               device: ["can't be blank"]
             }
    end

    test "invalid changeset with incorrect data types" do
      invalid_attrs = %{
        ip: 12345,
        user_agent: :atom,
        browser: nil,
        device: ["Array"]
      }

      changeset = Click.changeset(%Click{}, invalid_attrs)

      refute changeset.valid?
      assert errors_on(changeset) == %{
               ip: ["is invalid"],
               user_agent: ["is invalid"],
               browser: ["can't be blank"],
               device: ["is invalid"]
             }
    end

    test "valid changeset when updating a click" do
      click = %Click{id: 1, ip: "192.168.1.1", user_agent: "Mozilla/5.0", browser: "Chrome", device: "Desktop"}
      update_attrs = %{browser: "Firefox", device: "Tablet"}

      changeset = Click.changeset(click, update_attrs)

      assert changeset.valid?
      assert changeset.changes.browser == "Firefox"
      assert changeset.changes.device == "Tablet"
    end

    test "invalid changeset when updating with nil values" do
      click = %Click{id: 1, ip: "192.168.1.1", user_agent: "Mozilla/5.0", browser: "Chrome", device: "Desktop"}
      update_attrs = %{browser: nil, device: nil}

      changeset = Click.changeset(click, update_attrs)

      refute changeset.valid?
      assert errors_on(changeset) == %{
               browser: ["can't be blank"],
               device: ["can't be blank"]
             }
    end
  end
end

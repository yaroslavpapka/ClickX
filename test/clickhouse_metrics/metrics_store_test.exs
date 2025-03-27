defmodule ClickhouseMetrics.MetricsStoreTest do
  use ClickhouseMetrics.DataCase, async: true

  alias ClickhouseMetrics.{MetricsStore, Click, Repo}

  describe "add_click/4" do
    @valid_ip "192.168.1.1"
    @valid_user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    @valid_browser "Chrome 114.0"
    @valid_device "Desktop"

    test "successfully inserts a valid click into the database" do
      assert {:ok, %Click{} = click} =
               MetricsStore.add_click(@valid_ip, @valid_user_agent, @valid_browser, @valid_device)

      assert Repo.get(Click, click.id)
      assert click.ip == @valid_ip
      assert click.user_agent == @valid_user_agent
      assert click.browser == @valid_browser
      assert click.device == @valid_device
    end

    test "fails when IP address is missing" do
      assert {:error, changeset} = MetricsStore.add_click(nil, @valid_user_agent, @valid_browser, @valid_device)
      assert "can't be blank" in errors_on(changeset).ip
    end

    test "fails when user agent is missing" do
      assert {:error, changeset} = MetricsStore.add_click(@valid_ip, nil, @valid_browser, @valid_device)
      assert "can't be blank" in errors_on(changeset).user_agent
    end

    test "fails when browser is missing" do
      assert {:error, changeset} = MetricsStore.add_click(@valid_ip, @valid_user_agent, nil, @valid_device)
      assert "can't be blank" in errors_on(changeset).browser
    end

    test "fails when device is missing" do
      assert {:error, changeset} = MetricsStore.add_click(@valid_ip, @valid_user_agent, @valid_browser, nil)
      assert "can't be blank" in errors_on(changeset).device
    end

    test "fails when all fields are nil" do
      assert {:error, changeset} = MetricsStore.add_click(nil, nil, nil, nil)

      assert "can't be blank" in errors_on(changeset).ip
      assert "can't be blank" in errors_on(changeset).user_agent
      assert "can't be blank" in errors_on(changeset).browser
      assert "can't be blank" in errors_on(changeset).device
    end

    test "fails when IP address is invalid" do
      assert {:error, changeset} = MetricsStore.add_click(:invalid, @valid_user_agent, @valid_browser, @valid_device)
      assert "is invalid" in errors_on(changeset).ip
    end

    test "fails when device string contains forbidden characters" do
      assert {:error, changeset} = MetricsStore.add_click(@valid_ip, @valid_user_agent, @valid_browser, 3242)
      assert "is invalid" in errors_on(changeset).device
    end

  end
end

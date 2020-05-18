require "./spec_helper"

describe Url::Diff do
  it "detects scheme differences" do
    diffs = Url::Diff.compare(
      "http://example.com",
      "https://example.com")

    diffs.size.should eq 1
    kind = diffs.first.first
    kind.should eq ":scheme"
  end

  it "detects hostname differences" do
    diffs = Url::Diff.compare(
      "https://example1.com",
      "https://example.com")

    diffs.size.should eq 1
    kind = diffs.first.first
    kind.should eq ":hostname"
  end

  it "detects path differences" do
    diffs = Url::Diff.compare(
      "https://example.com/videos",
      "https://example.com/podcasts")

    diffs.size.should eq 1
    kind = diffs.first.first
    kind.should eq ":path"
  end

  it "detects query param differences when both exist" do
    diffs = Url::Diff.compare(
      "https://example.com?taters=cold",
      "https://example.com?taters=hot")

    diffs.size.should eq 1
    param, left, right = diffs.first
    param.should eq "taters"
    left.should_not eq right
  end

  it "detects query param left missing" do
    diffs = Url::Diff.compare(
      "https://example.com",
      "https://example.com?taters=hot")

    diffs.size.should eq 1
    param, left, right = diffs.first
    param.should eq "taters"
    left.should eq nil
    left.should_not eq right
  end

  it "detects query param right missing" do
    diffs = Url::Diff.compare(
      "https://example.com?taters=cold",
      "https://example.com?")

    diffs.size.should eq 1
    param, left, right = diffs.first
    param.should eq "taters"
    left.should eq "cold"
    left.should_not eq right
  end
end

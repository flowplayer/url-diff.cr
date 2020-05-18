require "./spec_helper"

describe Url::Diff do
  it "detects scheme differences" do
    left, right, diffs = Url::Diff.compare(
      "http://example.com",
      "https://example.com")

    diffs.size.should eq 1
    kind = diffs.first.first
    kind.should eq ":scheme"
  end

  it "detects hostname differences" do
    left, right, diffs = Url::Diff.compare(
      "https://example1.com",
      "https://example.com")

    diffs.size.should eq 1
    kind = diffs.first.first
    kind.should eq ":hostname"
  end

  it "detects path differences" do
    left, right, diffs = Url::Diff.compare(
      "https://example.com/videos",
      "https://example.com/podcasts")

    diffs.size.should eq 1
    kind = diffs.first.first
    kind.should eq ":path"
  end

  it "detects query param differences when both exist" do
    left, right, diffs = Url::Diff.compare(
      "https://example.com?taters=cold",
      "https://example.com?taters=hot")

    diffs.size.should eq 1
    param, left, right = diffs.first
    param.should eq "taters"
    left.should_not eq right
  end

  it "detects query param left missing" do
    left, right, diffs = Url::Diff.compare(
      "https://example.com",
      "https://example.com?taters=hot")

    diffs.size.should eq 1
    param, left, right = diffs.first
    param.should eq "taters"
    left.should eq nil
    left.should_not eq right
  end

  it "detects query param right missing" do
    left, right, diffs = Url::Diff.compare(
      "https://example.com?taters=cold",
      "https://example.com?")

    diffs.size.should eq 1
    param, left, right = diffs.first
    param.should eq "taters"
    left.should eq "cold"
    left.should_not eq right
  end

  it "handles macros in query params" do
    left, right, diffs = Url::Diff.compare(
      "https://vast.example.com/?ppid=[placeholder]&cmsid=[placeholder]&vid=[placeholder]",
      "https://vast.example.com/?ppid=1&cmsid=1&vid=1")
    diffs.size.should eq 3
  end
end

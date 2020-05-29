require "./spec_helper"

describe Url::Diff do
  it "detects scheme differences" do
    baseline, against, diffs = Url::Diff.compare(
      "http://example.com",
      "https://example.com")

    diffs.size.should eq 1
    kind = diffs.first.first
    kind.should eq ":scheme"
  end

  it "detects hostname differences" do
    baseline, against, diffs = Url::Diff.compare(
      "https://example1.com",
      "https://example.com")

    diffs.size.should eq 1
    kind = diffs.first.first
    kind.should eq ":hostname"
  end

  it "detects path differences" do
    baseline, against, diffs = Url::Diff.compare(
      "https://example.com/videos",
      "https://example.com/podcasts")

    diffs.size.should eq 1
    kind = diffs.first.first
    kind.should eq ":path"
  end

  it "detects query param differences when both exist" do
    baseline, against, diffs = Url::Diff.compare(
      "https://example.com?taters=cold",
      "https://example.com?taters=hot")

    diffs.size.should eq 1
    param, baseline, against = diffs.first
    param.should eq "taters"
    baseline.should_not eq against
  end

  it "detects query param baseline missing" do
    baseline, against, diffs = Url::Diff.compare(
      "https://example.com",
      "https://example.com?taters=hot")

    diffs.size.should eq 1
    param, baseline, against = diffs.first
    param.should eq "taters"
    baseline.should eq nil
    baseline.should_not eq against
  end

  it "detects query param against missing" do
    baseline, against, diffs = Url::Diff.compare(
      "https://example.com?taters=cold",
      "https://example.com?")

    diffs.size.should eq 1
    param, baseline, against = diffs.first
    param.should eq "taters"
    baseline.should eq "cold"
    baseline.should_not eq against
  end

  it "handles macros in query params" do
    baseline, against, diffs = Url::Diff.compare(
      "https://vast.example.com/?ppid=[placeholder]&cmsid=[placeholder]&vid=[placeholder]",
      "https://vast.example.com/?ppid=1&cmsid=1&vid=1")
    diffs.size.should eq 3
  end
end

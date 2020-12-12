# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImageVariant, type: :model do
  it "returns dimensions to use when resizing image variant" do
    options = ImageVariant.variant_options(:small_avatar)
    size = ImageVariant::VARIANTS[:small_avatar]
    expect(options[:resize_to_fill]).to eq([size, size, crop: :centre])

    options = ImageVariant.variant_options(:greenfield)
    size = ImageVariant::VARIANTS[:greenfield]
    expect(options[:resize_to_fill]).to eq([size, size, crop: :centre])
  end

  it "verifies known variants" do
    expect do
      ImageVariant.verify(:large_avatar)
    end.to_not raise_error
  end

  it "raises an exception verifying unknown variants" do
    expect do
      ImageVariant.verify(:unknown)
    end.to raise_error(ArgumentError)
  end

  context "with uploaded attachment" do
    let(:attachment) do
      playlists(:will_studd_rockfort).cover_image
    end

    before do
      file_fixture_pathname('blue_de_bresse.jpg').open do |file|
        attachment.upload(file)
      end
    end

    it "returns a single image variant instance" do
      image_variant = ImageVariant.new(attachment, variant: :greenfield)
      expect(image_variant.attachment).to eq(attachment)
      expect(image_variant.variant_name).to eq(:greenfield)
      expect(image_variant.variant_options).to eq(
        resize_to_fill: [1500, 1500, crop: :centre],
        saver: { optimize_coding: true, quality: 68, strip: true }
      )
    end

    it "raises exception when trying to instantiate variant for nonexistent variant name" do
      expect do
        ImageVariant.new(attachment, variant: :unknown)
      end.to raise_error(ArgumentError)
    end

    it "returns a single active storage variant" do
      variant = ImageVariant.variant(attachment, variant: :greenfield)
      expect(variant).to be_kind_of(ActiveStorage::VariantWithRecord)
    end

    it "raises exception when trying to get storage variant for nonexistent variant name" do
      expect do
        ImageVariant.variant(attachment, variant: :unknown)
      end.to raise_error(ArgumentError)
    end
  end
end

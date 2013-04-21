# -*- coding: utf-8 -*-

require 'spec_helper'

describe Nude do
  context 'not nude images' do
    it 'damita.jpg is not nude image' do
      expect(Nude.nude?(image_path('damita.jpg'))).to be_false
    end

    it 'damita2.jpg is not nude image' do
      expect(Nude.nude?(image_path('damita2.jpg'))).to be_false
    end
  end

  context 'nude images' do
    it 'test2.jpg is nude image' do
      expect(Nude.nude?(image_path('test2.jpg'))).to be_true
    end

    it 'test6.jpg is nude image' do
      expect(Nude.nude?(image_path('test6.jpg'))).to be_true
    end
  end
end

# encoding: utf-8
require 'spec_helper'

# Test SRP functions.
# Some values are from http://srp.stanford.edu/demo/demo.html using 256 bit values.
#
describe SIRP do
  include SIRP
  before :all do
    @N = '115b8b692e0e045692cf280b436735c77a5a9e8a9e7ed56c965f87db5b2a2ece3'.to_i(16)
    @g = 2
    @username = 'user'
    @password = 'password'
    @salt = '16ccfa081895fe1ed0bb'
    @a = '7ec87196e320a2f8dfe8979b1992e0d34439d24471b62c40564bb4302866e1c2'.to_i(16)
    @b = '8143e2f299852a05717427ea9d87c6146e747d0da6e95f4390264e55a43ae96'.to_i(16)
  end

  context 'hex_to_bytes' do
    it 'should calculate expected results' do
      expect(hex_to_bytes('abcdef0123456789'))
        .to eq [171, 205, 239, 1, 35, 69, 103, 137]
    end
  end

  context 'num_to_hex' do
    it 'should calculate expected results' do
      num = 999_999_999_999
      expect(num_to_hex(num))
        .to eq 'e8d4a50fff'
      expect('e8d4a50fff'.hex).to eq num
    end
  end

  context 'sha_hex' do
    it 'should calculate expected results for SHA1' do
      str = 'foo'
      str_unpacked = str.unpack('H*')[0]
      str_sha = Digest::SHA1.hexdigest(str)
      expect(sha_hex(str_unpacked, Digest::SHA1)).to eq str_sha
    end

    it 'should calculate expected results for SHA256' do
      str = 'foo'
      str_unpacked = str.unpack('H*')[0]
      str_sha = Digest::SHA256.hexdigest(str)
      expect(sha_hex(str_unpacked, Digest::SHA256)).to eq str_sha
    end
  end

  context 'sha_str' do
    it 'should calculate expected results for SHA1' do
      expect(sha_str('foo', Digest::SHA1))
        .to eq '0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33'
    end

    it 'should calculate expected results for SHA256' do
      expect(sha_str('foo', Digest::SHA256))
        .to eq '2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae'
    end
  end

  context 'mod_exp' do
    it 'should calculate expected results' do
      a = 2988348162058574136915891421498819466320163312926952423791023078876139
      b = 2351399303373464486466122544523690094744975233415544072992656881240319
      m = 10**40
      c = mod_exp(a, b, m)
      expect(c).to eq 1527229998585248450016808958343740453059
    end
  end

  context 'H' do
    it 'should calculate expected results' do
      a = 2988348162058574136915891421498819466320163312926952423791023078876139
      b = 2351399303373464486466122544523690094744975233415544072992656881240319
      c = H(Digest::SHA1, a, b)
      expect(c).to eq 870206349645559849154987479939336526106829135959
    end

    it 'should raise an error when given invalid args' do
      expect { H(Digest::SHA1, 1, '123456789abcdef') }
        .to raise_error(RuntimeError, 'Bit width does not match - client uses different prime')
    end
  end

  context 'calc_k' do
    it 'should calculate expected results' do
      k = calc_k(@N, @g, Digest::SHA1)
      expect(('%x' % k)).to eq 'dbe5dfe0704fee4c85ff106ecd38117d33bcfe50'
      expect(('%b' % k).length).to eq 160
    end
  end

  context 'calc_x' do
    it 'should calculate expected results' do
      x = calc_x(@username, @password, @salt, Digest::SHA1)
      expect(('%x' % x)).to eq 'bdd0a4e1c9df4082684d8d358b8016301b025375'
      expect(('%b' % x).length).to eq 160
    end
  end

  context 'calc_x_hex' do
    it 'should calculate expected results' do
      x = calc_x_hex(sha_str(@password, Digest::SHA1), @salt, Digest::SHA1)
      expect(('%x' % x)).to eq 'df9e191c7566592db9d09f7f3b46a16b0d782966'
      expect(('%b' % x).length).to eq 160
    end
  end

  context 'calc_u' do
    it 'should calculate expected results' do
      aa = 'b1c4827b0ce416953789db123051ed990023f43b396236b86e12a2c69638fb8e'
      bb = 'fbc56086bb51e26ee1a8287c0a7f3fd4e067e55beb8530b869b10b961957ff68'
      u = calc_u(aa, bb, @N, Digest::SHA1)
      expect(('%x' % u)).to eq 'c60b17ddf568dd5743d0e3ba5621646b742432c5'
      expect(('%b' % u).length).to eq 160
    end
  end

  context 'calc_v' do
    it 'should calculate expected results' do
      x = 'bdd0a4e1c9df4082684d8d358b8016301b025375'.to_i(16)
      v = calc_v(x, @N, @g)
      expect(('%x' % v)).to eq 'ce36e101ed8c37ed98ba4e441274dabd1062f3440763eb98bd6058e5400b6309'
      expect(('%b' % v).length).to eq 256
    end
  end

  context 'calc_A' do
    it 'should calculate expected results' do
      aa = calc_A(@a, @N, @g)
      expect(('%x' % aa)).to eq 'b1c4827b0ce416953789db123051ed990023f43b396236b86e12a2c69638fb8e'
      expect(('%b' % aa).length).to eq 256
    end
  end

  context 'calc_B' do
    it 'should calculate expected results' do
      k = 'dbe5dfe0704fee4c85ff106ecd38117d33bcfe50'.to_i(16)
      v = 'ce36e101ed8c37ed98ba4e441274dabd1062f3440763eb98bd6058e5400b6309'.to_i(16)
      bb = calc_B(@b, k, v, @N, @g)
      expect(('%x' % bb)).to eq 'fbc56086bb51e26ee1a8287c0a7f3fd4e067e55beb8530b869b10b961957ff68'
      expect(('%b' % bb).length).to eq 256
    end
  end

  context 'calc_client_S' do
    it 'should calculate expected results' do
      bb = 'fbc56086bb51e26ee1a8287c0a7f3fd4e067e55beb8530b869b10b961957ff68'.to_i(16)
      k = 'dbe5dfe0704fee4c85ff106ecd38117d33bcfe50'.to_i(16)
      x = 'bdd0a4e1c9df4082684d8d358b8016301b025375'.to_i(16)
      u = 'c60b17ddf568dd5743d0e3ba5621646b742432c5'.to_i(16)
      ss = calc_client_S(bb, @a, k, x, u, @N, @g)
      expect(('%x' % ss)).to eq 'a606c182e364d2c15f9cdbeeeb63bb00c831d1da65eedc1414f21157d0312a5a'
      expect(('%b' % ss).length).to eq 256
    end
  end

  context 'calc_server_S' do
    it 'should calculate expected results' do
      aa = 'b1c4827b0ce416953789db123051ed990023f43b396236b86e12a2c69638fb8e'.to_i(16)
      v = 'ce36e101ed8c37ed98ba4e441274dabd1062f3440763eb98bd6058e5400b6309'.to_i(16)
      u = 'c60b17ddf568dd5743d0e3ba5621646b742432c5'.to_i(16)
      ss = calc_server_S(aa, @b, v, u, @N)
      expect(('%x' % ss)).to eq 'a606c182e364d2c15f9cdbeeeb63bb00c831d1da65eedc1414f21157d0312a5a'
      expect(('%b' % ss).length).to eq 256
    end
  end

  context 'calc_M' do
    it 'should calculate expected results' do
      xaa = 'b1c4827b0ce416953789db123051ed990023f43b396236b86e12a2c69638fb8e'
      xbb = 'fbc56086bb51e26ee1a8287c0a7f3fd4e067e55beb8530b869b10b961957ff68'
      xss = 'a606c182e364d2c15f9cdbeeeb63bb00c831d1da65eedc1414f21157d0312a5a'
      xkk = sha_hex(xss, Digest::SHA1)
      expect(xkk).to eq '5844898ea6e5f5d9b737bc0ba2fb9d5edd3f8e67'
      mm = calc_M(@N, @g, @username, @salt, xaa, xbb, xkk, Digest::SHA1)
      expect(mm).to eq '9344fca22a7919afd46000e91f137e567e3fdd68'
    end
  end

  context 'calc_H_AMK' do
    it 'should calculate expected results' do
      xaa = 'b1c4827b0ce416953789db123051ed990023f43b396236b86e12a2c69638fb8e'
      xmm = 'd597503056af882d5b27b419302ac7b2ea9d7468'
      xkk = '5844898ea6e5f5d9b737bc0ba2fb9d5edd3f8e67'
      h_amk = calc_H_AMK(xaa, xmm, xkk, Digest::SHA1)
      expect(('%x' % h_amk)).to eq '530fccc1c4aa82ae5c5cdfa8bdec987c6032451d'
    end
  end
end

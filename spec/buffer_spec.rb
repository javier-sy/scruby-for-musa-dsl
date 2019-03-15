require_relative 'helper'

require 'date'
require 'tempfile'

require 'scruby/buffer'
require 'scruby/bus'
require 'scruby/server'

include Scruby

describe Buffer do
  describe "messaging" do
    before :all do
      @defsound = File.join(Scruby::Test::SOUND_DIR, 'a11wlk01-44_1.aiff')
      @pinksound = File.join(Scruby::Test::SOUND_DIR, 'SinedPink.aiff')
      @robotsound = File.join(Scruby::Test::SOUND_DIR, 'a11wlk01-44_1.aiff')
      @old_stdout = $stdout
      $stdout = StringIO.new
      @server = Server.new
      @server.boot
      @server.send '/dumpOSC', 3
      wait
      @server.log.clear
    end

    after :all do
      @server.quit
      wait
      $stdout = @old_stdout
    end

    describe 'Buffer.read' do
      before do
        @server.log.clear
        @buffer = Buffer.read @server, @defsound
        wait
      end

      it "should instantiate and send /b_allocRead message" do
        @buffer.should be_a(Buffer)
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_allocRead", #{ @buffer.buffnum }, "#{@defsound}", 0, -1, DATA\[20\] \]}
      end

      it "should allow passing a completion message"
    end

    describe 'Buffer.allocate' do

      before :example do
        @server.log.clear
        @buffer = Buffer.allocate @server, 44100 * 8.0, 2
        wait
      end

      it "should call allocate and send /b_alloc message" do
        @buffer.should be_a(Buffer)
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_alloc", #{ @buffer.buffnum }, 352800, 2, 0 \]}
        output.should =~ /69 00 00 00  00 00 00 01  48 ac 44 00  00 00 00 02/
      end

      it "should allow passing a completion message"
    end

    describe 'Buffer.cueSoundFile' do
      before do
        @server.log.clear
        @buffer = Buffer.cue_sound_file @server, @defsound, 0, 1
        wait
      end

      it "should send /b_alloc message and instantiate" do
        @buffer.should be_a(Buffer)
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_alloc", #{ @buffer.buffnum }, 32768, 1, DATA\[128\] \]}
        output.should =~ /2f 62 5f 61  6c 6c 6f 63  00 00 00 00  2c 69 69 69/ # /b_alloc etc.
      end

      it "should allow passing a completion message"
    end

    describe '#free' do
      before do
        @server.log.clear
        @buffer  = Buffer.allocate @server, 44100 * 10.0, 2
        @buffer2 = Buffer.allocate @server, 44100 * 10.0, 2
        @bnum    = @buffer2.buffnum
        @buffer2.free
        wait
      end

      it "should remove itself from the server @buffers array and send free message" do
        @buffer2.buffnum.should be_nil
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_free", #{@bnum}, 0 \]}
      end

      it "should allow passing a completion message"
    end

    describe 'Buffer.alloc_consecutive' do
      before do
        @server.log.clear
        @buffers = Buffer.alloc_consecutive 8, @server, 4096, 2
        wait
      end

      it "should send alloc message for each Buffer and instantiate" do
        @buffers.count.should eq 8
        output = unwind(@server.log)
        @buffers.each do |buff|
          output.should =~ %r{\[ "/b_alloc", #{buff.buffnum}, 4096, 2, 0 \]}
        end
      end

      it "should allow passing a message"
    end

    describe 'Buffer.read_channel' do
      before do
        @server.log.clear
        @buffer = Buffer.read_channel @server, @pinksound, :channels => [0]
        wait
      end

      it "should allocate and send /b_allocReadChannel message" do
        @buffer.should be_a(Buffer)
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_allocReadChannel", #{@buffer.buffnum}, "#{@pinksound}", 0, -1, 0, DATA\[20\] \]}
      end
    end

    describe '#read' do
      before do
        @server.log.clear
        @buffer  = Buffer.allocate(@server, 44100 * 10.0, 2).read(@robotsound)
        wait
      end

      it "should send message" do
        @buffer.should be_a(Buffer)
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_read", #{@buffer.buffnum}, "#{@robotsound}", 0, -1, 0, 0, DATA\[20\] \]}
      end

      it "should allow passing a completion message"
    end

    describe '#close' do
      before do
        @server.log.clear
        @buffer  = Buffer.read(@server, @defsound).close
        wait
      end

      it "should send message" do
        @buffer.should be_a(Buffer)
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_close", #{@buffer.buffnum}, 0 \]}
      end

      it "should allow passing a completion message"
    end

    describe '#zero' do
      before do
        @server.log.clear
        @buffer  = Buffer.read(@server, @defsound).zero
        wait
      end

      it "should send message" do
        @buffer.should be_a(Buffer)
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_zero", #{@buffer.buffnum}, 0 \]}
      end

      it "should allow passing a completion message"
    end

    describe '#cue_sound_file' do
      before do
        @server.log.clear
        @buffer  = Buffer.allocate(@server, 44100, 1).cue_sound_file( @robotsound )
        wait
      end

      it "should send message" do
        @buffer.should be_a(Buffer)
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_read", #{@buffer.buffnum}, "#{@robotsound}", 0, 44100, 0, 1, 0 \]}
      end

      it "should allow passing a completion message"
    end

    describe '#write' do
      before do
        @server.log.clear
        @testsound = File.join(Scruby::Test::SOUND_DIR, 'test.aiff')
        @buffer = Buffer.allocate(@server, 44100 * 10.0, 2).write(@testsound, "aiff", "int16", 0, 0, true);
        # FIXME: @server.flush
        wait
      end

      it { @buffer.should be_a(Buffer) }

      it "should send message" do
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_write", #{@buffer.buffnum}, "#{@testsound}", "aiff", "int16", 0, 0, 1, 0 \]}
      end

      it "should have a default path" do
        @server.log.clear
        buffer = Buffer.allocate(@server, 44100 * 10.0, 2).write(nil, "aiff", "int16", 0, 0, true);
        wait
        output = unwind(@server.log)
        output.should =~ %r{\[ "/b_write", #{buffer.buffnum}, "/.+/Scruby/\d\d\d\d.+\.aiff", "aiff", "int16", 0, 0, 1, 0 \]}
      end

      it "should allow passing a completion message"
    end
  end
end

defmodule RtmpServer.StreamPipeline do
  use Membrane.Pipeline

  @impl true
  def handle_init(_ctx, socket) do
    validator = %RtmpServer.Validator{pipeline_pid: self()}

    spec = [
      child(:source, %Membrane.RTMP.Source.Bin{
        message_validator: validator
      })
    ]

    {[spec: spec], %{socket: socket, stream_id: nil}}
  end

  @impl true
  def handle_setup(_ctx, state) do
    {[], state}
  end

  @impl true
  def handle_notification(:socket_control_needed, :source, _ctx, %{socket: socket} = state) do
    Membrane.RTMP.Source.give_socket_control(get_child(:source), socket)
    {[], state}
  end

  def handle_notification(_other, _element, _ctx, state) do
    {[], state}
  end

  @impl true
  def handle_info({:stream_id, stream_id}, _ctx, state) do
    hls_directory = "hls/#{stream_id}"

    File.mkdir_p!(hls_directory)
    File.mkdir_p!("recordings")

    spec = [
      get_child(:source) |> via_out(Pad.ref(:audio)) ~> child(:tee_audio, Membrane.Tee.Master),
      get_child(:source) |> via_out(Pad.ref(:video)) ~> child(:tee_video, Membrane.Tee.Master),
      child(:hls, %Membrane.HLS.Sink{
        muxer: Membrane.MP4.Muxer.CMAF,
        directory: hls_directory,
        segment_duration: Membrane.Time.seconds(4),
        partial_segment_duration: Membrane.Time.seconds(2)
      }),
      child(:mp4_muxer, %Membrane.MP4.Muxer.ISOM{}),
      child(:file_sink, %Membrane.File.Sink{location: "recordings/#{stream_id}.mp4"}),

      get_child(:tee_audio) ~> get_child(:hls) |> via_in(Pad.ref(:input, :audio)),
      get_child(:tee_video) ~> get_child(:hls) |> via_in(Pad.ref(:input, :video)),
      get_child(:tee_audio) ~> get_child(:mp4_muxer) |> via_in(Pad.ref(:input, :audio)),
      get_child(:tee_video) ~> get_child(:mp4_muxer) |> via_in(Pad.ref(:input, :video)),
      get_child(:mp4_muxer) ~> get_child(:file_sink)
    ]

    {[spec: spec], %{state | stream_id: stream_id}}
  end

  def handle_info(_msg, _ctx, state) do
    {[], state}
  end
end

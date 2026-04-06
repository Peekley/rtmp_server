defmodule RtmpServer.StreamPipeline do
  use Membrane.Pipeline

  alias Membrane.HTTPAdaptiveStream
  alias Membrane.HTTPAdaptiveStream.Sink.ManifestConfig
  alias Membrane.HTTPAdaptiveStream.Sink.TrackConfig
  alias Membrane.File.Sink

  @impl true
  def handle_init(_ctx, opts) do
    case {opts[:client_ref], opts[:signaling]} do
      {client_ref, nil} when not is_nil(client_ref) ->
        rtmp_init(client_ref, opts[:stream_id])

      {nil, signaling} when not is_nil(signaling) ->
        webrtc_init(signaling, opts[:stream_id])

      _ ->
        raise "Must provide either :client_ref (RTMP) or :signaling (WebRTC)"
    end
  end

  defp rtmp_init(client_ref, stream_id) do
    hls_dir = "hls/#{stream_id}"
    File.mkdir_p!(hls_dir)
    File.mkdir_p!("records")

    spec = [
      child(:rtmp_source, %Membrane.RTMP.SourceBin{client_ref: client_ref}),

      get_child(:rtmp_source) |> via_out(Pad.ref(:audio)) |> child(:tee_audio, Membrane.Tee.Master),
      get_child(:rtmp_source) |> via_out(Pad.ref(:video)) |> child(:tee_video, Membrane.Tee.Master),

      child(:hls_sink, %HTTPAdaptiveStream.Sink{
        manifest_config: %ManifestConfig{
          name: "index",
          module: HTTPAdaptiveStream.HLS
        },
        storage: %HTTPAdaptiveStream.Storages.FileStorage{directory: hls_dir},
        track_config: %TrackConfig{}
      }),

      child(:mp4_muxer, %Membrane.MP4.Muxer.ISOM{}),
      child(:file_sink, %Sink{location: "records/#{stream_id}.mp4"}),

      get_child(:tee_audio) |> via_in(Pad.ref(:input, :audio)) |> get_child(:hls_sink),
      get_child(:tee_video) |> via_in(Pad.ref(:input, :video)) |> get_child(:hls_sink),

      get_child(:tee_audio) |> via_in(Pad.ref(:input, :audio)) |> get_child(:mp4_muxer),
      get_child(:tee_video) |> via_in(Pad.ref(:input, :video)) |> get_child(:mp4_muxer),
      get_child(:mp4_muxer) |> get_child(:file_sink)
    ]

    {[spec: spec], %{stream_id: stream_id, type: :rtmp}}
  end

  defp webrtc_init(signaling, stream_id) do
    hls_dir = "hls/#{stream_id}"
    File.mkdir_p!(hls_dir)
    File.mkdir_p!("records")

    spec = [
      child(:webrtc_source, %Membrane.WebRTC.Source{
        signaling: signaling,
        allowed_video_codecs: [:h264, :vp8],
        ice_servers: [%{urls: ["stun:stun.l.google.com:19302"]}]
      })
    ]

    {[spec: spec], %{stream_id: stream_id, type: :webrtc, tracks_setup: false}}
  end

  @impl true
  def handle_notification({:new_tracks, tracks}, :webrtc_source, _ctx, state = %{tracks_setup: false}) do
    tee_specs =
      for track <- tracks, reduce: [] do
        acc ->
          tee_name = String.to_atom("tee_#{track.kind}")
          pad = Pad.ref(:output, track.id)

          [
            child(tee_name, Membrane.Tee.Master),
            get_child(:webrtc_source) |> via_out(pad) |> get_child(tee_name)
            | acc
          ]
      end

    sink_specs = [
      child(:hls_sink, %HTTPAdaptiveStream.Sink{
        manifest_config: %ManifestConfig{
          name: "index",
          module: HTTPAdaptiveStream.HLS
        },
        storage: %HTTPAdaptiveStream.Storages.FileStorage{directory: "hls/#{state.stream_id}"},
        track_config: %TrackConfig{}
      }),

      child(:mp4_muxer, %Membrane.MP4.Muxer.ISOM{}),
      child(:file_sink, %Sink{location: "records/#{state.stream_id}.mp4"})
    ]

    hls_links =
      []
      |> add_link_if_track(tracks, :audio, :hls_sink, :tee_audio)
      |> add_link_if_track(tracks, :video, :hls_sink, :tee_video)

    recording_links =
      []
      |> add_link_if_track(tracks, :audio, :mp4_muxer, :tee_audio)
      |> add_link_if_track(tracks, :video, :mp4_muxer, :tee_video)
      |> Kernel.++([get_child(:mp4_muxer) |> get_child(:file_sink)])

    all_specs = tee_specs ++ sink_specs ++ hls_links ++ recording_links

    {[spec: all_specs], %{state | tracks_setup: true}}
  end

  def handle_notification(_any, _element, _ctx, state), do: {[], state}

  defp add_link_if_track(specs, tracks, kind, target, source_tee) do
    if Enum.any?(tracks, &(&1.kind == kind)) do
      link = get_child(source_tee)
             |> via_in(Pad.ref(:input, kind))
             |> get_child(target)

      [link | specs]
    else
      specs
    end
  end
end

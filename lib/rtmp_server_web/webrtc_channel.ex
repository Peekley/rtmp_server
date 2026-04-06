defmodule RtmpServerWeb.WebRTCChannel do
  use Phoenix.Channel
  alias Membrane.WebRTC.Signaling

  def join("webrtc:" <> _stream_id, _payload, socket) do
    signaling = Signaling.new()
    {:ok, _pid} = start_pipeline(socket.assigns.stream_id, signaling)
    {:ok, assign(socket, signaling: signaling)}
  end

  def handle_in("offer", %{"sdp" => sdp}, socket) do
    Signaling.handle_offer(socket.assigns.signaling, sdp)
    {:noreply, socket}
  end

  def handle_in("candidate", %{"candidate" => candidate}, socket) do
    Signaling.handle_candidate(socket.assigns.signaling, candidate)
    {:noreply, socket}
  end

  def handle_info({:answer, sdp}, socket) do
    push(socket, "answer", %{sdp: sdp})
    {:noreply, socket}
  end

  def handle_info({:candidate, candidate}, socket) do
    push(socket, "candidate", %{candidate: candidate})
    {:noreply, socket}
  end

  defp start_pipeline(stream_id, signaling) do
    Membrane.Pipeline.start_link(RtmpServer.StreamPipeline, signaling: signaling, stream_id: stream_id)
  end
end

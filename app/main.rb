def tick args
  cow_frame_index ||= Numeric.frame_index(
    start_at: 0,
    hold_for: 0.5.seconds,
    count: 2,
    repeat: true
  )
  args.state.cow ||= {
    x: 500,
    y: 500,
    w: 128,
    h: 64,
    path: "sprites/cow_idle_16x8_2.png",
    tile_x: 16 * cow_frame_index,
    tile_w: 16,
    tile_h: 8
  }
  
  args.state.cow.x += 12 if args.inputs.keyboard.right
  args.state.cow.x -= 12 if args.inputs.keyboard.left
  args.state.cow.y += 12 if args.inputs.keyboard.up
  args.state.cow.y -= 12 if args.inputs.keyboard.down

  args.outputs << args.state.cow
end
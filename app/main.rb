def tick args
  # camera variables
  args.state.world.w      ||= 2500
  args.state.world.h      ||= 2500

  args.state.camera.x                ||= 640
  args.state.camera.y                ||= 300
  args.state.camera.scale            ||= 1.0
  args.state.camera.show_empty_space ||= :yes

  args.state.grass_patches ||= []

  args.state.grass_spawn_tick ||= Kernel.tick_count

  if args.state.grass_spawn_tick.elapsed_time >= 1.0.seconds
    args.state.grass_patches << grass(Numeric.rand(200..2200), Numeric.rand(200..2200))
    args.state.grass_spawn_tick = Kernel.tick_count
  end


  args.state.cow ||= {
    x: 0,
    y: 0,
    w: 128,
    h: 64,
    path: "sprites/cow_idle_16x8_2.png",
    tile_x: 16,
    tile_w: 16,
    tile_h: 8
  }

  cow_frame_index ||= Numeric.frame_index(
    start_at: 0,
    hold_for: 0.5.seconds,
    count: 2,
    repeat: true
  )
  args.state.cow.tile_x = 16 * cow_frame_index

  # render scene
  args.outputs[:scene].w = args.state.world.w
  args.outputs[:scene].h = args.state.world.h

  args.outputs[:scene].solids << { x: 0, y: 0, w: args.state.world.w, h: args.state.world.h, r: 50, g: 100, b: 70 }
  args.outputs[:scene].solids << args.state.grass_patches
  args.outputs[:scene].sprites << args.state.cow

  # render camera
  scene_position = calc_scene_position args
  args.outputs.sprites << { 
    x: scene_position.x,
    y: scene_position.y,
    w: scene_position.w,
    h: scene_position.h,
    path: :scene }

  # move player
  if args.inputs.directional_angle
    args.state.cow.x += args.inputs.directional_angle.vector_x * 5
    args.state.cow.y += args.inputs.directional_angle.vector_y * 5
    args.state.cow.x  = args.state.cow.x.clamp(0, args.state.world.w - args.state.cow.size)
    args.state.cow.y  = args.state.cow.y.clamp(0, args.state.world.h - args.state.cow.size)
  end

  # +/- to zoom in and out
  if args.inputs.keyboard.plus && Kernel.tick_count.zmod?(3)
    args.state.camera.scale += 0.05
  elsif args.inputs.keyboard.hyphen && Kernel.tick_count.zmod?(3)
    args.state.camera.scale -= 0.05
  elsif args.inputs.keyboard.key_down.tab
    if args.state.camera.show_empty_space == :yes
      args.state.camera.show_empty_space = :no
    else
      args.state.camera.show_empty_space = :yes
    end
  end

  args.state.camera.scale = args.state.camera.scale.greater(0.1)
end

def grass(x, y)
  {
    x: x,
    y: y,
    w: 64,
    h: 64,
    r: 110,
    g: 120,
    b: 50,
    primitive_marker: :solid
  }
end

def calc_scene_position args
  result = { 
    x: args.state.camera.x - (args.state.cow.x * args.state.camera.scale),
    y: args.state.camera.y - (args.state.cow.y * args.state.camera.scale),
    w: args.state.world.w * args.state.camera.scale,
    h: args.state.world.h * args.state.camera.scale,
    scale: args.state.camera.scale 
  }

  return result if args.state.camera.show_empty_space == :yes

  if result.w < args.grid.w
    result.merge!(x: (args.grid.w - result.w).half)
  elsif (args.state.cow.x * result.scale) < args.grid.w.half
    result.merge!(x: 10)
  elsif (result.x + result.w) < args.grid.w
    result.merge!(x: - result.w + (args.grid.w - 10))
  end

  if result.h < args.grid.h
    result.merge!(y: (args.grid.h - result.h).half)
  elsif (result.y) > 10
    result.merge!(y: 10)
  elsif (result.y + result.h) < args.grid.h
    result.merge!(y: - result.h + (args.grid.h - 10))
  end

  result
end
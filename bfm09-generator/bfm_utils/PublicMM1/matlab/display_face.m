function handle = display_face (shp, tex, tl, rp, mode_az,mode_ev, particle_id)
	
    shp = reshape(shp, [ 3 prod(size(shp))/3 ])'; 
    
    %Affine
    RotAngle = roty(rp.phi);
    tmp = RotAngle * shp';
    shp = tmp';
    
    RotAngle = rotx(rp.elevation);
    tmp = RotAngle * shp';
    shp = tmp';
    
    tex = reshape(tex, [ 3 prod(size(tex))/3 ])'; 
    tex = min(tex, 255);
    
    if isequal(particle_id, []) == 1
        particle_id = 1;
    end
    
    handle = figure(particle_id);
    set(handle,'Visible','off');
    set(handle, 'PaperPositionMode','auto');
    
    set(gcf, 'Renderer', 'opengl');
    
    fig_pos = get(handle, 'Position');
	
    fig_pos(3) = rp.width;
    fig_pos(4) = rp.height;
    set(handle, 'Position', fig_pos);
    set(handle, 'ResizeFcn', @resizeCallback);

    if particle_id == 1
       % regular
        mesh_h = trimesh(...
	    tl, shp(:, 1), shp(:, 3), shp(:, 2), ...
    	    'EdgeColor', 'none', ...
	    'FaceVertexCData', tex/255, 'FaceColor', 'interp', ...
	    'FaceLighting', 'phong' ...
	);
    elseif particle_id == 2
      % textureless (sculpture like)
        mesh_h = trimesh(...
	   tl, shp(:, 1), shp(:, 3), shp(:, 2), ...
	   'EdgeColor', 'none', ...
	   'FaceVertexCData', tex/255, 'FaceColor', [0.5 0.5 0.5], ...
	   'FaceLighting', 'gouraud', ...
	   'AmbientStrength', 1.0 ...
	);
    elseif particle_id == 3
	% albedo
        mesh_h = trimesh(...
	    tl, shp(:, 1), shp(:, 3), shp(:, 2), ...
    	    'EdgeColor', 'none', ...
	    'FaceVertexCData', tex/255, 'FaceColor', 'interp', ...
	    'FaceLighting', 'none' ...
	);
    elseif particle_id == 4
	% normals
        tr = triangulation(tl, shp(:, 1), shp(:, 3), shp(:, 2));
        vn = vertexNormal(tr);
        vn = ((vn + 1)./2).*255;
        vn = [vn(:,3) vn(:,1) vn(:,2)];
        mesh_h = trimesh(...
            tl, shp(:, 1), shp(:, 3), shp(:, 2), ...
            'EdgeColor', 'none', ...
            'FaceVertexCData', vn/255, 'FaceColor', 'interp', ...
            'FaceLighting', 'none', ...
            'AmbientStrength', 1.0 ...
        );
    elseif particle_id == 5
	% shading
        mesh_h = trimesh(...
	   tl, shp(:, 1), shp(:, 3), shp(:, 2), ...
	   'EdgeColor', 'none', ...
	   'FaceColor', [1 1 1], ...
	   'FaceLighting', 'gouraud', ...
	   'AmbientStrength', 1.0 ...
	);
    elseif particle_id == 6
       % with backface culling
        tr = triangulation(tl, shp(:, 1), shp(:, 3), shp(:, 2));
        vn = vertexNormal(tr);
        dotProd = vn * [-1.0e+02, 1882900, -8700]';
        tex = tex/255;
        tex(dotProd <= 0, :) = nan;
	positive = sum(isnan(tex(33885:36950)));
	negative = sum(isnan(tex(18185:21250)));
        if positive - negative > 750 && rp.phi > 0
            tex(33885:36950,:) = nan; % 1.5 ear
	end;
        if positive - negative < 750 > 0 && rp.phi < 0
            tex(18185:21250, :) = nan; % -1.5 ear
        end;
        mesh_h = trimesh(...
	    tl, shp(:, 1), shp(:, 3), shp(:, 2), ...
    	    'EdgeColor', 'none', ...
	    'FaceVertexCData', tex, 'FaceColor', 'interp', ...
	    'FaceLighting', 'phong' ...
	);
    end;

    set(gca, ...
	'DataAspectRatio', [ 1 1 1 ], ...
	'PlotBoxAspectRatio', [ 1 1 1 ], ...
	'Units', 'pixels', ...
	'GridLineStyle', 'none', ...
	'Position', [ 0 0 fig_pos(3) fig_pos(4) ], ...
	'Visible', 'off', 'box', 'off', ...
	'Projection', 'perspective' ...
    ); 
	

    set(handle, 'Color', [ 1 1 1 ]); 
    view(180,0);

    material([.5, .5, .1 1  ])

    camlight(mode_az,mode_ev);
	

%% ------------------------------------------------------------CALLBACK--------
function resizeCallback (obj, eventdata)
	
	fig = gcbf;
	fig_pos = get(fig, 'Position');

	axis = findobj(get(fig, 'Children'), 'Tag', 'Axis.Head');
	set(axis, 'Position', [ 0 0 fig_pos(3) fig_pos(4) ]);
	

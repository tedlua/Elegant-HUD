--[[
     ______              ______           _   ____________   _   _ _   _______
    |  ___|             |  _  \         | |  | ___ \ ___ \ | | | | | | |  _  \
    | |_ _ __ ___  ___  | | | |__ _ _ __| | _| |_/ / |_/ / | |_| | | | | | | |
    |  _| '__/ _ \/ _ \ | | | / _` | '__| |/ /    /|  __/  |  _  | | | | | | |
    | | | | |  __/  __/ | |/ / (_| | |  |   <| |\ \| |     | | | | |_| | |/ /
    \_| |_|  \___|\___| |___/ \__,_|_|  |_|\_\_| \_\_|     \_| |_/\___/|___/


    Coded by: ted.lua (http://steamcommunity.com/id/tedlua/)
]]

  if !CLIENT then return end

  local function IsSandbox()
      if gmod.GetGamemode().Name == 'Sandbox' then return true end
      return false
  end

  local ranks = {
      [ 'superadmin' ] = { name = 'Super Administrator', color = Color( 199, 44, 44 ) },
      [ 'developer' ] = { name = 'Developer', color = Color( 199, 44, 44 ) },
      [ 'admin' ] = { name = 'Administrator', color = Color( 241, 196, 15 ) },
      [ 'moderator' ] = { name = 'Moderator', color = Color( 52, 152, 219 ) },
      [ 'donator' ] = { name = 'Donator', color = Color( 155, 89, 182 ) },
      [ 'vip' ] = { name = 'VIP', color = Color( 155, 89, 182 ) }
  }

  local function TranslateGroup( x, c )
      if not c then
          if ranks[ x ] then
              return ranks[ x ].name
          else
              return 'User'
          end
      else
          if ranks[ x ] then
              return ranks[ x ].color
          else
              return Color( 255, 255, 255 )
          end
      end
  end

  surface.CreateFont( "Elegant_HUD_Font_Generic", { font = "Calibri", size = 18, weight = 800 } )
  surface.CreateFont( "Elegant_HUD_Font_Data", { font = "Arial", size = 18, weight = 800 } )
  surface.CreateFont( "Elegant_HUD_Font_Ammo", { font = "Calibri", size = 22, weight = 800 } )
  surface.CreateFont( "Elegant_HUD_Font_Agenda", { font = "Calibri", size = 26, weight = 800 } )

  local health_icon = Material( "icon16/heart.png" )
  local shield_icon = Material( "icon16/shield.png" )
  local cash_icon = Material( "icon16/money.png" )
  local star_icon = Material( "icon16/star.png" )
  local tick_icon = Material( "icon16/tick.png" )
  local medal_icon = Material( "icon16/medal_gold_2.png" )


  local maxBarSize = 215

  local function DrawFillableBar( x, y, w, h, baseCol, fillCol, icon, txt )
      DrawRect( x, y, w, h, baseCol )
      DrawRect( x, y, w, h, fillCol )
  end

  local function DrawRect( x, y, w, h, col )
      surface.SetDrawColor( col )
      surface.DrawRect( x, y, w, h )
  end

  local function DrawText( msg, fnt, x, y, c, align )
      draw.SimpleText( msg, fnt, x, y, c, align and align or TEXT_ALIGN_CENTER )
  end

  local function DrawOutlinedRect( x, y, w, h, t, c )
     surface.SetDrawColor( c )
     for i = 0, t - 1 do
         surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
     end
  end

  local v = { "DarkRP_HUD", "CHudBattery", "CHudHealth", "CHudAmmo" }

  hook.Add( 'HUDShouldDraw', 'HUD_HIDE_DRP', function( vs )
      if table.HasValue( v, vs ) then return false end
  end )

  local function CreateModelHead()
      model = vgui.Create("DModelPanel")
      function model:LayoutEntity( Entity ) return end
  end
  hook.Add( 'InitPostEntity', 'HUD_GIVE_HEAD', CreateModelHead )

  local function CreateImageIcon( icon, x, y, col, val )
      surface.SetDrawColor( col )
      surface.SetMaterial( icon )
      local w, h = 16, 16
      if val then
          surface.SetDrawColor( Color( 255, 255, 255 ) )
      end
      surface.DrawTexturedRect( x, y, w, h )
  end

  local function GetBarSize( data )
      return ( maxBarSize / 100 ) * data < maxBarSize and ( maxBarSize / 100 ) * data or maxBarSize
  end

  local function DrawAmmo( self )
      if IsValid( self:GetActiveWeapon() ) and self:Alive() then
          local plane, size, hY = ScrW() - 115, self:GetActiveWeapon():Clip1(), ScrH() - 113
          local ammo, reserve = self:GetActiveWeapon():Clip1() < 0 and 0 or self:GetActiveWeapon():Clip1(), self:GetAmmoCount( self:GetActiveWeapon():GetPrimaryAmmoType() )
          local x, y = ScrW() - 220, ScrH() - 75
          DrawRect( x, y, 200, 40, Color( 14, 14, 14 ) )
          DrawRect( x, y, 5, 40, Color( 231, 76, 60 ) )
          DrawOutlinedRect( x, y, 200, 40, 2, Color( 0, 0, 0, 250 ) )
          DrawText( self:GetActiveWeapon():GetPrintName(), "Elegant_HUD_Font_Ammo", x + 100, y - 1, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
          DrawText( ammo .. '/' .. reserve, "Elegant_HUD_Font_Ammo", x + 100, y + 16, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
      end
  end

  local function DrawAgenda( self )
    if !self:getAgendaTable() then return end
    local x, y, w, h = 5, 5, 500, 120
    local sX, sY, num = 30, 10, #self:getAgendaTable()
    DrawRect( x, y, w, 110, Color( 22, 22, 22, 240 ) )
    DrawRect( x, 30, w, 2, Color( 0, 128, 255 ) )
    DrawRect( x, 5, 3, 110, Color( 0, 128, 255 ) )
    DrawText( string.upper( self:getAgendaTable().Title ), "Elegant_HUD_Font_Agenda", x + 10, y, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
    local text = LocalPlayer():getDarkRPVar( "agenda" ) or ""
	text = DarkRP.textWrap( text, "Elegant_HUD_Font_Agenda", 480 )
    draw.DrawNonParsedText( text, "Elegant_HUD_Font_Agenda", 18, 35, Color( 255, 255, 255 ), 0 )
  end

  local function Lockdown()
      if GetGlobalBool( "DarkRP_LockDown" ) then
          DrawRect( 5, ScrH() - 193, 320, 25, Color( 18, 18, 18, 250 ) )
          DrawOutlinedRect( 5, ScrH() - 193, 320, 25, 1, Color( 120, 0, 0 ) )
          DrawText( 'LOCKDOWN ACITVE!', "Elegant_HUD_Font_Agenda", 75, ScrH() - 194, Color( 120, 0, 0 ), TEXT_ALIGN_LEFT )
      end
  end

  local function CreateHUD()

      local self = LocalPlayer()

      local bX, bY, bW, bH = 5, ScrH() - 140, 320, 110 -- The main box with shit in it
      local tX, tY, tW, tH = 5, ScrH() - 166, 320, 25 -- The title bar box (above main box)
      local mX, mY, mW, mH = 10, ScrH() - 133, 81, 78 -- The model background and model box position

      local back = Color( 12, 12, 12 )
      local through = Color( 0, 0, 0, 250 )


      DrawRect( bX, bY, bW, bH, back )
      DrawRect( tX, tY, tW, tH, back )
      DrawRect( 5, ScrH() - 141, 320, 20, back )
      DrawRect( mX, mY, mW, mH, Color( 44, 44, 44, 130 ) )

      --DrawOutlinedRect( bX, bY, bW, bH, 2, through )
      --DrawOutlinedRect( tX, tY, tW, tH, 2, through )
      DrawOutlinedRect( mX, mY, mW, mH, 2, through )

      local job = team.GetName( self:Team() )

      DrawText( self:Nick(), "Elegant_HUD_Font_Generic", 15, ScrH() - 159, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )

      if gmod.GetGamemode().Name == 'DarkRP' then DrawText( job, "Elegant_HUD_Font_Generic", 315, ScrH() - 159, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT ) end

      model:SetModel( self:GetModel() )
      model:SetPos( mX, mY - 10 )
      model:SetSize( mW, mH + 7 )
      model:SetCamPos( Vector( 15, -5, 65 ) )
      model:SetLookAt( Vector( 0, 0, 65 ) )
      model:SetAnimated( true )

      local hX, hY, hW, hH = 120, ScrH() - 132, 190, 24

      local divide = 5
      local offset = 20

      DrawRect( hX - offset, hY, maxBarSize + divide / 2, hH, Color( 26, 26, 26 ) )
      DrawRect( hX + divide, hY, GetBarSize( self:Health() ) - divide / 2 - offset, hH, Color( 220, 20, 60, 190 ) )
      DrawText( self:Health() > 0 and self:Health() .. "%" or 0 .. "%", "Elegant_HUD_Font_Data", 215, hY + 3, Color( 255, 255, 255 ) )

      DrawRect( hX - offset, hY + 28, maxBarSize + divide / 2, hH, Color( 26, 26, 26 ) )
      DrawRect( hX + divide, hY + 28, GetBarSize( self:Armor() > 0 and self:Armor() or 0 ) - divide / 2 - offset, hH, Color( 30, 144, 255 ) )
      DrawText( self:Armor() > 0 and self:Armor() .. "%" or 0 .. "%", "Elegant_HUD_Font_Data", 215, hY + 31, Color( 255, 255, 255 ) )

      DrawRect( hX - offset, hY + 55, maxBarSize + divide / 2, hH, Color( 26, 26, 26 ) )
      DrawRect( hX + divide, hY + 55, GetBarSize( 100 ) - divide / 2 - offset, hH, gmod.GetGamemode().Name == 'DarkRP' and Color( 46, 204, 133 ) or Color( 52, 152, 219 ) )

      CreateImageIcon( health_icon, 104, ScrH() - 128, Color( 255, 0, 0 ) )
      CreateImageIcon( shield_icon, 103, ScrH() - 101, Color( 30,144,255 ) )
      CreateImageIcon( gmod.GetGamemode().Name == 'DarkRP' and cash_icon or medal_icon, 104, ScrH() - 73, Color( 255, 255, 255 ) )

      if gmod.GetGamemode().Name == 'DarkRP' then
          CreateImageIcon( star_icon, 30, ScrH() - 53, Color( 40, 40, 40 ), self:isWanted() )
          CreateImageIcon( tick_icon, 55, ScrH() - 52, Color( 40, 40, 40 ), self:getDarkRPVar("HasGunlicense") )
      end

      DrawText( gmod.GetGamemode().Name == 'DarkRP' and DarkRP.formatMoney( self:getDarkRPVar( "money" ) ) or TranslateGroup( self, false ), "Elegant_HUD_Font_Data", 215, ScrH() - 73, gmod.GetGamemode().Name == 'DarkRP' and Color( 255, 255, 255 ) or TranslateGroup( self, true ), TEXT_ALIGN_CENTER )
      DrawAmmo( self )
      if gmod.GetGamemode().Name == 'DarkRP' then DrawAgenda( self ) Lockdown() end

  end

  hook.Add( 'HUDPaint', 'HUD_DRAW_HUD', function() CreateHUD() end )

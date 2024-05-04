settings
{
	priority=1
	exclude.where = !process.is_explorer
	showdelay = 200
	// Options to allow modification of system items
	modify.remove.duplicate=1
	tip.enabled=true
}

import 'imports/theme.nss'
import 'imports/images.nss'

import 'imports/modify.nss'

menu(mode="multiple" title="Pin/Unpin" image=icon.pin)
{
}

menu(mode="multiple" title=title.more_options image=icon.more_options)
{
}

theme
{
	name = "modern"

	view = view.small

	background
	{
		color = #24273a
		opacity = 100
		// effect = 2
	}

	item
	{
		opacity = 100

		prefix = 1

		text
		{
			normal = #cad3f5
			select = #cad3f5
			normal-disabled = #a5adcb
			select-disabled = #a5adcb
		}

		back
		{
			select = #494d64
			select-disabled = #363a4f
		}
	}

	font
	{
		size = 14
	 	name = "JetBrainsMono Nerd Font Mono"
	 	weight = 2
	 	italic = 0
	}

	border
	{
		enabled = true
		size = 1
		color = #b7bdf8
		opacity = 100
		radius = 2
	}

	shadow
	{
		enabled = true
		size = 5
		opacity = 5
		color = #181926
	}

	separator
	{
		size = 1
		color = #363a4f
	}

	symbol
	{
		normal = #b7bdf8
		select = #b7bdf8
		normal-disabled = #a5adcb
		select-disabled = #a5adcb
	}

	image
	{
		enabled = true
		color = [#cad3f5, #b7bdf8, #24273a]
	}
}

import 'imports/terminal.nss'
import 'imports/file-manage.nss'
import 'imports/develop.nss'
import 'imports/goto.nss'
import 'imports/taskbar.nss'


remove ( find="Git GUI Here" )
remove ( find="Git Bash Here" )
remove ( find="Open Git GUI Here" )
remove ( find="Open Git Bash Here" )
remove ( find="Send With NordVPN Meshnet" )
remove ( find="Neuigkeiten und interessante Themen" )
remove ( find="Cortana-Schaltfläche anzeigen" )
remove ( find="Taskansicht-Schaltfläche anzeigen" )
remove ( find="Kontakte auf der Taskleiste anzeigen" )
remove ( find="Windows Ink-Arbeitsbereich anzeigen (Schaltfläche)" )
remove ( find="Bildschirmtastatur anzeigen (Schaltfläche)" )
remove ( find="Touchpad anzeigen (Schaltfläche)" )
remove ( find="Behandeln von Kompatibilitätsproblemen" )
remove ( find="Mit Microsoft Defender überprüfen..." )
remove ( find="Mit VLC media player wiedergeben" )
remove ( find="Zur VLC media player Wiedergabeliste hinzufügen" )












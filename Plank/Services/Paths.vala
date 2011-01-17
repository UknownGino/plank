//  
//  Copyright (C) 2011 Robert Dyer
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
// 

using Plank.Services.Logging;

namespace Plank.Services.Paths
{
	// This class follows the XDG Base Directory specification:
	//   http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
	public class Paths : GLib.Object
	{
		// User's home folder - $HOME
		public static File HomeFolder { get; protected set; }
		
		
		// $XDG_CONFIG_HOME - defaults to $HOME/.config
		public static File XdgConfigHomeFolder { get; protected set; }
		
		// $XDG_DATA_HOME - defaults to $HOME/.local/share
		public static File XdgDataHomeFolder { get; protected set; }
		
		// $XDG_CACHE_HOME - defaults to $HOME/.cache
		public static File XdgCacheHomeFolder { get; protected set; }
		
		// $XDG_DATA_DIRS - defaults to /usr/local/share/:/usr/share/
		public static unowned List<File> XdgDataDirFolders { get; protected set; }
		
		
		// defaults to XdgConfigHomeFolder/plank
		public static File UserConfigFolder { get; protected set; }
		
		// defaults to XdgDataHomeFolder/plank
		public static File UserDataFolder { get; protected set; }
		
		// defaults to XdgCacheHomeFolder/plank
		public static File UserCacheFolder { get; protected set; }
		
		static construct
		{
			// get environment-based settings
			HomeFolder = File.new_for_path (Environment.get_home_dir ());
			
			
			// get XDG Base Directory settings
			string? xdg_config_home = Environment.get_variable ("XDG_CONFIG_HOME");
			string? xdg_data_home   = Environment.get_variable ("XDG_DATA_HOME");
			string? xdg_cache_home  = Environment.get_variable ("XDG_CACHE_HOME");
			string? xdg_data_dirs   = Environment.get_variable ("XDG_DATA_DIRS");
			
			
			// determine directories based on XDG with fallbacks
			if (xdg_config_home == null || xdg_config_home.length == 0)
				XdgConfigHomeFolder = HomeFolder.get_child (".config");
			else
				XdgConfigHomeFolder = File.new_for_path (xdg_config_home);
			
			if (xdg_data_home == null || xdg_data_home.length == 0)
				XdgDataHomeFolder = HomeFolder.get_child (".local").get_child (".share");
			else
				XdgDataHomeFolder = File.new_for_path (xdg_data_home);
			
			if (xdg_cache_home == null || xdg_cache_home.length == 0)
				XdgCacheHomeFolder = HomeFolder.get_child (".cache");
			else
				XdgCacheHomeFolder = File.new_for_path (xdg_cache_home);
			
			List<File> dirs = new List<File> ();
			if (xdg_data_dirs == null || xdg_data_dirs.length == 0) {
				dirs.append (File.new_for_path ("/usr/local/share"));
				dirs.append (File.new_for_path ("/usr/share"));
			} else {
				foreach (string path in xdg_data_dirs.split (":"))
					dirs.append (File.new_for_path (path));
			}
			XdgDataDirFolders = dirs;
			
			
			// set the XDG Base Directory specified directories to use
			UserConfigFolder = XdgConfigHomeFolder.get_child ("plank");
			UserDataFolder   = XdgDataHomeFolder.get_child ("plank");
			UserCacheFolder  = XdgCacheHomeFolder.get_child ("plank");
			
			
			// ensure all writable directories exist
			ensure_directory_exists (UserConfigFolder);
			ensure_directory_exists (UserDataFolder);
			ensure_directory_exists (UserCacheFolder);
		}
		
		public static bool ensure_directory_exists (File dir)
		{
			if (!dir.query_exists ())
				try {
					dir.make_directory_with_parents ();
					return true;
				} catch {
					Logger.fatal<Paths> ("Could not access the directory '%s' or create it.  Plank will not work properly unless this folder is wriable.".printf (dir.get_path ()));
				}
			
			return false;
		}
	}
}
// Default includes, to acces Qt/QML
// and Substance 3D Painter APIs
import QtQuick 2.7
import Painter 1.0


// Root object for the plugin
PainterPlugin
{
    
	// Disable update and server settings
	// since we don't need them
	tickIntervalMS: -1 // Disabled Tick
	jsonServerPort: -1 // Disabled JSON server

	// Implement the OnCompleted function
	// This event is used to build the UI
	// once the plugin as been loaded by Substance 3D Painter
	Component.onCompleted:
	{
		// Create a toolbar button
		var InterfaceButton = alg.ui.addToolBarWidget("toolbar.qml");

		// Connect the function to the button
		if( InterfaceButton )
		{
			InterfaceButton.clicked.connect( exportTextures );
		}
	}

	// Custom function called by the Button,
	// this is the core of the plugin
	function exportTextures()
	{
        var vmatFileData = []
        alg.log.info( "test")
		// Catch errors in the script during execution
		try
		{
			// Verify if a project is open before 
			// trying to export something
			if( !alg.project.isOpen() )
			{
				return;
			}

			// Retrieve the currently selected Texture Set (and sub-stack if any)
			var MaterialPath = alg.texturesets.getActiveTextureSet()
			var UseMaterialLayering = MaterialPath.length > 1
			var TextureSetName = MaterialPath[0]
			var StackName = ""

			if( UseMaterialLayering )
			{
				StackName = MaterialPath[1]
			}

			// Retrieve the Texture Set information
			var Documents = alg.mapexport.documentStructure()
			var Resolution = alg.mapexport.textureSetResolution( TextureSetName )
			var Channels = null

			for( var Index in Documents.materials )
			{
				var Material = Documents.materials[Index]

				if( TextureSetName == Material.name )
				{
					for( var SubIndex in Material.stacks )
					{
						if( StackName == Material.stacks[SubIndex].name )
						{
							Channels = Material.stacks[SubIndex].channels
							break
						}
					}
				}
			}

			// Create the export settings
			var Settings = {
				"padding":"Infinite",
				"dithering":"disbaled", // Hem, yes...
				"resolution": Resolution,
				"bitDepth": 16,
				"keepAlpha": false
			}

			// Build the base of the export path
			// Files will be located next to the project
			var BasePath = alg.fileIO.urlToLocalFile( alg.project.url() )
			BasePath = BasePath.substring( 0, BasePath.lastIndexOf("/") );

			// Export the each channel
			for( var Index in Channels )
			{
				// Create the stack path, which defines the channel to export
				var Path = Array.from( MaterialPath )
				Path.push( Channels[Index] )

				// Build the filename for the texture to export
				var Filename = BasePath + "/" + TextureSetName

				if( UseMaterialLayering )
				{
					Filename += "_" + StackName
				}

				Filename += "_" + Channels[Index] + ".png"

				// Perform the export
				alg.mapexport.save( Path, Filename, Settings )
				alg.log.info( "Exported: " + Filename )

                // VMAT Creation
                
                vmatFileData.push(Filename);


			}

        try
        {
			// How the fuck do I create a file with this fucking shit ass language
         vmatFileData.join("");
         alg.log.info("Trying to log vmatfiledata\n")
         alg.log.info(vmatFileData.toString())
         alg.fileexport.save(Path, "Output.txt", vmatFileData)
        } 
        catch ( error )
        {
            alg.log.exception( error )
        }

		}
		catch( error )
		{
			// Print errors in the log window
			alg.log.exception( error )
		}
	}
}
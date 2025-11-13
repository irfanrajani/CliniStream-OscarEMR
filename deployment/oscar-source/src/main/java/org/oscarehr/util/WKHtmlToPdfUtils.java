/**
 *
 * Copyright (c) 2005-2012. Centre for Research on Inner City Health, St. Michael's Hospital, Toronto. All Rights Reserved.
 * This software is published under the GPL GNU General Public License.
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * This software was written for
 * Centre for Research on Inner City Health, St. Michael's Hospital,
 * Toronto, Ontario, Canada
 */

package org.oscarehr.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.IOException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.logging.log4j.Logger;
import io.woo.htmltopdf.*;

import oscar.OscarProperties;

public class WKHtmlToPdfUtils {
	private static final Logger logger = MiscUtils.getLogger();
	private static final int PROCESS_COMPLETION_CYCLE_CHECK_PERIOD = 250;
	private static final int MAX_NO_CHANGE_COUNT = 40000 / PROCESS_COMPLETION_CYCLE_CHECK_PERIOD;
	private static final String CONVERT_COMMAND;
	private static final String CONVERT_ARGS;
	static {
		String convertCommand = OscarProperties.getInstance().getProperty("WKHTMLTOPDF_COMMAND");
		if (convertCommand != null) CONVERT_COMMAND = convertCommand;
		else throw (new RuntimeException("Properties file is missing property : WKHTMLTOPDF_COMMAND"));
		
		String convertParameters = OscarProperties.getInstance().getProperty("WKHTMLTOPDF_ARGS");
		if (convertParameters != null) CONVERT_ARGS = convertParameters;
		else CONVERT_ARGS = null;
	}

	private WKHtmlToPdfUtils() {
		// not meant for instantiation
	}

	/**
	 * This method should convert the html page at the sourceUrl into a pdf as returned by the byte[].
	 * the method is superloaded through convertToPdf(sourceUrl, outputFile) to either internal or external converters
	 */

	public static byte[] convertToPdf(String sourceUrl) throws IOException {
	   File outputFile = null;
	   try {
		  outputFile = File.createTempFile("wkhtmltopdf.", ".pdf");
		  outputFile.deleteOnExit();

		  convertToPdf(sourceUrl, outputFile);

		  try (FileInputStream fis = new FileInputStream(outputFile)){
			 return IOUtils.toByteArray(fis);
		  }

	   } finally {
		  if (outputFile != null) {
			 outputFile.delete();
		  }
	   }
	}
	
	/**
	 * This method switches between internal and external methods to convert the pdf
	 * To use the internal method provide an empty value for WKHTMLTOPDF_COMMAND in oscar.properties
	 * Do not call this method without being sure as to the uniqueness of the temp file 
	 * and how it is consumed or you risk leaving files or overwriting them....
	 */
	public static void convertToPdf(String sourceUrl, File outputFile)  throws IOException {

		if (CONVERT_COMMAND.equalsIgnoreCase("internal")) {
			convertToPdfinternal(sourceUrl, outputFile);
		} else {
			convertToPdfexternal(sourceUrl, outputFile);		
		}
	}
	
	/**
	 * This method should convert the html page at the sourceUrl into a pdf written to the outputFile. 
	 * This method requires the binary executable wkhtmltopdf to be installed on the machine. 
	 * @throws Exception 
	 */
	public static void convertToPdfexternal(String sourceUrl, File outputFile) throws IOException {
		String outputFilename = outputFile.getCanonicalPath();

		// example command : wkhtmltopdf-i386 "https://127.0.0.1:8443/oscar/eformViewForPdfGenerationServlet?fdid=2&parentAjaxId=eforms" /tmp/out.pdf
		ArrayList<String> command = new ArrayList<String>();
		command.add(CONVERT_COMMAND);
		if (CONVERT_ARGS != null) {
			for(String arg : CONVERT_ARGS.split("\\s"))
				command.add(arg);
		}
		command.add(sourceUrl);
		command.add(outputFilename);

		logger.info(command);
		runtimeExec(command, outputFilename);
	}

	/**
	 * This method should convert the html page at the sourceUrl into a pdf written to the outputFile.
	 * It uses the internal io.woo.htmltopdf class for conversion 
	 * which in turn requires multiple binary dependencies installed in either Focal or Bullseye
	 * @throws Exception 
	 */

	public static void convertToPdfinternal(String sourceUrl, File outputFile) throws IOException {
	   String filePath = outputFile.getCanonicalPath();
	   logger.debug("In:"+sourceUrl);
	   logger.debug("Out:"+filePath);
	   HashMap<String, String> htmlToPdfSettings = new HashMap<String, String>();
	   htmlToPdfSettings.put("load.blockLocalFileAccess", "false");
	   String lookback = "";
	   if (CONVERT_ARGS != null) {
			for(String arg : CONVERT_ARGS.split("\\s")) {
				if (arg.equalsIgnoreCase("--print-media-type")) { htmlToPdfSettings.put("web.printMediaType", "true");}
				//if (arg.equalsIgnoreCase("--enable-smart-shrinking")) { htmlToPdfSettings.put("web.enableIntelligentShrinking", "true");} //default
				if (arg.equalsIgnoreCase("--disable-smart-shrinking")) { htmlToPdfSettings.put("web.enableIntelligentShrinking", "false");}
				if (arg.equalsIgnoreCase("--disable-javascript")) { htmlToPdfSettings.put("web.enableJavascript", "false");}
				if (arg.equalsIgnoreCase("--no-stop-slow-scripts")) { htmlToPdfSettings.put("load.stopSlowScript", "false");}
				if (lookback.equalsIgnoreCase("--minimum-font-size") && arg != null && arg.matches("[0-9]+")) { htmlToPdfSettings.put("web.minimumFontSize", arg);} //int  
				if (lookback.equalsIgnoreCase("--javascript-delay") && arg != null && arg.matches("[0-9]+")) { htmlToPdfSettings.put("load.jsdelay", arg);} //default 200 in ms
				if (lookback.equalsIgnoreCase("--zoom") && arg != null && arg.matches("[0-9.]+")) { htmlToPdfSettings.put("load.zoomFactor", arg);}  //float
				lookback = arg;
			}
		}

	   HtmlToPdf htmlToPdf = HtmlToPdf.create().object(HtmlToPdfObject.forUrl(sourceUrl, htmlToPdfSettings));
	   logger.debug("HtmlToPdf Object created");	
	   
	   boolean success = htmlToPdf.convert(filePath);
	   logger.info(sourceUrl + " written to " + filePath);
	}
	/**
	 * Normally you can just run a command and it'll complete. The problem with doing that is if the command takes a while and you need to know when it's completed, like if it's cpu intensive like image processing and possibly in this case pdf creation.
	 * This method will run the command and it has 2 stopping conditions, 1) normal completion as per the process.exitValue() or if the process does not appear to be doing anything. As a result there's a polling thread to check the out put file to see if
	 * anything is happening. The example is if you're doing image processing and you're scaling an image with say imagemagick it could take 5 minutes to finish. You don't want to set a time out that long, but you don't want to stop if it it's proceeding
	 * normally. Normal proceeding is defined by the out put file is still changing. If the out put file isn't changing, and it's taking "a while" then we would assume it's failed some how or hung or stalled at which point we'll terminate it.
	 * @throws Exception 
	 */
	private static void runtimeExec(ArrayList<String> command, String outputFilename) throws IOException {
		File f = new File(outputFilename);
		Process process = Runtime.getRuntime().exec(command.toArray(new String[0]));

		// Drain inputstreams (Magenta health)
        InputStream[] iStreams = {
            process.getErrorStream(),
            process.getInputStream()
        };

        List<Thread> threads = new ArrayList<Thread>();
        for (final InputStream is : iStreams) {
            threads.add(
                new Thread(new Runnable() {
                    public void run() {
                        try {
                            while (true) {
                                int res = is.read();
                                if (res == -1) {
                                    break;
                                }
                            }
                        } catch (Exception e) {
                            throw new RuntimeException(e);
                        }
                    }
            }));
            threads.get(threads.size() - 1).start();
        }

        for (Thread t : threads) {
            try {
                t.join();
            } catch(Exception e) {
                throw new RuntimeException(e);
            }
        }
        
        
		long previousFileSize = 0;
		int noFileSizeChangeCounter = 0;

		try {
			while (true) {
				try {
					Thread.sleep(PROCESS_COMPLETION_CYCLE_CHECK_PERIOD);
				} catch (InterruptedException e) {
					logger.error("Thread interrupted", e);
				}

				try {
					int exitValue = process.exitValue();

					if (exitValue != 0) {
						logger.error("Error running command : " + command);

						String errorMsg = StringUtils.trimToNull(IOUtils.toString(process.getInputStream()));
						if (errorMsg != null) logger.error(errorMsg);

						errorMsg = StringUtils.trimToNull(IOUtils.toString(process.getErrorStream()));
						if (errorMsg != null) logger.error(errorMsg);
						
						//404 error returns code 2 but file is still converted if file passed and not url so we check before throwing exception
						if( exitValue != 2 )
							throw new IOException("Cannot convert html file to pdf");
					}

					return;
				} catch (IllegalThreadStateException e) {
					long tempSize = f.length();

					logger.info("Progress output filename=" + outputFilename + ", filesize=" + tempSize);

					if (tempSize != previousFileSize) noFileSizeChangeCounter = 0;
					else {
						noFileSizeChangeCounter++;

						if (noFileSizeChangeCounter > MAX_NO_CHANGE_COUNT) break;
					}
				}
			}

			logger.error("Error, process appears stalled. command=" + command);
		} finally {
			process.destroy();			
		}
	}

}

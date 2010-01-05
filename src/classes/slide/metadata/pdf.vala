/**
 * Pdf metadata information
 *
 * This file is part of pdf-presenter-console.
 *
 * pdf-presenter-console is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3 of the License.
 *
 * pdf-presenter-console is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * pdf-presenter-console; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

using GLib;

namespace org.westhoffswelt.pdfpresenter.slide.Metadata {
    /**
     * Metadata for Pdf files
     */
    public class Pdf: Base
    {
        /**
         * Poppler document which belongs to the associated pdf file
         */
        protected Poppler.Document document;

        /**
         * Pdf page width
         */
        protected double page_width;

        /**
         * Pdf page height
         */
        protected double page_height;

        /**
         * Number of pages in the pdf document
         */
        protected uint page_count;

        /**
         * Base constructor taking the file url to the pdf file
         */
        public Pdf( string url ) {
            base( url );
        
            this.document = this.open_pdf_document( url );
            
            // Cache some often used values to minimize thread locking in the
            // future.
            MutexLocks.poppler.lock();
            this.page_count = this.document.get_n_pages();
            this.document.get_page( 0 ).get_size( 
                out this.page_width,
                out this.page_height
            );
            MutexLocks.poppler.unlock();
        }

        /**
         * Return the number of pages in the pdf document
         */
        public override uint get_slide_count() {
            return this.page_count;
        }

        /**
         * Return the width of the first page of the loaded pdf document.
         *
         * In presentations all pages will have the same size in most cases,
         * therefore this value is assumed to be useful.
         */
        public double get_page_width() {
            return this.page_width;
        }

        /**
         * Return the height of the first page of the loaded pdf document.
         *
         * In presentations all pages will have the same size in most cases,
         * therefore this value is assumed to be useful.
         */
        public double get_page_height() {
            return this.page_height;
        }

        /**
         * Return the Poppler.Document associated with this file
         */
        public Poppler.Document get_document() {
            return this.document;
        }

        /**
         * Open a given pdf document url and return a Poppler.Document for it.
         */
        protected Poppler.Document open_pdf_document( string url ) {
            var file = File.new_for_uri( url );
            
            Poppler.Document document = null;

            MutexLocks.poppler.lock();
            try {
                document = new Poppler.Document.from_file( 
                    file.get_uri(),
                    null
                );
            }
            catch( GLib.Error e ) {
                error( "Unable to open pdf file: %s", e.message );
            }            
            MutexLocks.poppler.unlock();

            return document;
        }
    }
}

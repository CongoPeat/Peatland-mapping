pro Crezee_et_al_2022_Nature_Geoscience_IDL_code_Maximum_Likelihood_peatland_extent
CPU, TPOOL_NTHREADS=1
close, /all

;; Code developed by Bart Crezee, Greta Dargie, and Ed Mitchard to map peatland extent across the central Congo Basin based on 5 landcover classes.

;; If using this code, please cite both:
;; Crezee et al., 2022. Maps of central Congo Basin peat thickness and carbon stocks based on extensive field data. Nature Geoscience
;; Dargie et al., 2017. Age, extent and carbon storage of the central Congo Basin peatland complex. Nature

; Set up model constants
xdims = 24137L     ; this must correspond with the samples number in the ENVI header file
ydims = 18687L     ; this must correspond with the lines number in the ENVI header file
nbands = 6         ; this must correspond with the band number in the ENVI header file
nclasses = 5       ; this must correspond with number of classes specified below
lookup=indgen(3,nclasses+1)*10
pos=lindgen(nbands)
accuracy = fltarr(nclasses)
outtemp=intarr(xdims, ydims)

; Set up one .csv file for each class containing lat/lon only
; Terra_firme is used here as shorthand for Non-peat forming forests
; class names must correspond with the start of each csv file containing the datapoints

infolderpath = "C:\.."    ; insert file path to input folder here
outfolderpath = "C:\.."   ; insert file path to output folder here
RSfilepath = "C:\.."      ; insert file path to ENVI file with 6-band PCA result
classnames = ['WATER', 'SAVANNAH', 'TERRA_FIRME', 'PALM_DOMINATED_SWAMP', 'HARDWOOD_SWAMP']
classnames1 = ['Unclassified', 'WATER', 'SAVANNAH', 'TERRA_FIRME', 'PALM_DOMINATED_SWAMP', 'HARDWOOD_SWAMP']

spectralmeans = fltarr(nbands, nclasses)
spectralstdv=fltarr(nbands, nclasses)
spectralcov=fltarr(nbands, nbands, nclasses)

; Select datapoints
nptsclass=[172,476,632,188,268]            ; specify the number of datapoints for each of the 5 classes here
nptstrain=round((nptsclass*2)/3.)
nptstest=round(nptsclass/3.)

print, "nptsclass: ", nptsclass
print, "nptstrain: ", nptstrain
print, "nptstest: ", nptstest

wat=fltarr(2,nptsclass[0])
sav=fltarr(2,nptsclass[1])
tef=fltarr(2,nptsclass[2])
psw=fltarr(2,nptsclass[3])
hsw=fltarr(2,nptsclass[4])

wat_train=fltarr(2,nptstrain[0])
sav_train=fltarr(2,nptstrain[1])
tef_train=fltarr(2,nptstrain[2])
psw_train=fltarr(2,nptstrain[3])
hsw_train=fltarr(2,nptstrain[4])

wat_test=fltarr(2,nptstest[0])
sav_test=fltarr(2,nptstest[1])
tef_test=fltarr(2,nptstest[2])
psw_test=fltarr(2,nptstest[3])
hsw_test=fltarr(2,nptstest[4])

randomnumbers = fltarr(5, max(nptsclass))


data = bytarr(xdims, ydims, nbands)

; open output files
  For i = 0, 4 do begin
  
  outfilename=outfolderpath+"\Count_class_type_"+classnames[i]
  openw, i+1, outfilename
  writeu, i+1, outtemp
  close, i+1

  Endfor 
  
  outaccuracyname=outfolderpath+"\Accuracy_perclass_perrun.txt"
  openw, 7, outaccuracyname
  printf, 7, classnames
  
  outconfusionname=outfolderpath+"\Confusion_data_perrun_perclass.txt"
  openw, 8, outconfusionname
  
  
  outareaname=outfolderpath+"\Numpixels_perclass_perrun.txt"
  openw,9, outareaname
  printf, 9, "run_number", classnames

; open ground points
; Use these .csv file names in the input folder, with all ground point lat/long per class
    
   openr, 6, infolderpath+"\"+classnames[0]+"_ROIs_LAT_LONG.csv" & READF, 6, wat & close, 6
   openr, 6, infolderpath+"\"+classnames[1]+"_ROIs_LAT_LONG.csv" & READF, 6, sav & close, 6 
   openr, 6, infolderpath+"\"+classnames[2]+"_ROIs_LAT_LONG.csv" & READF, 6, tef & close, 6
   openr, 6, infolderpath+"\"+classnames[3]+"_ROIs_LAT_LONG.csv" & READF, 6, psw & close, 6
   openr, 6, infolderpath+"\"+classnames[4]+"_ROIs_LAT_LONG.csv" & READF, 6, hsw & close, 6
   
; open data

envi_open_file, RSFilepath, r_fid=datafid  
envi_file_query, datafid, nb=nb, dims=dims, pos=pos
print, "dims", dims

print, "reading RSFile into IDL"
openu, 6, RSFilepath & readu, 6, data & close, 6
PRINT, "data excerpt", DATA[1000:1010, 3000]
    


;;;;;;;;;;;;;;;;;;; START MAIN LOOP       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

For z = 0, 999 do begin   ; change this number depending on the number of runs required.
  
  Print, "doing iteration #", z

; For i = 0,1000
; generate random number string for each input set of ground control points


; DUPLICATE FOR OTHER 5 CLASSES
indices = lonarr(nptsclass[0])
indices = (randomu(seed, nptsclass[0]) * nptsclass[0])
indices = sort(indices)
wat_train = wat[*,indices[0:(nptstrain[0]-1)]]
wat_test= wat[*, indices[nptstrain[0]:(nptsclass[0]-1)]]
print, wat_test

indices = lonarr(nptsclass[1])
indices = (randomu(seed, nptsclass[1]) * nptsclass[1])
indices = sort(indices)
sav_train = sav[*,indices[0:(nptstrain[1]-1)]]
sav_test= sav[*, indices[nptstrain[1]:(nptsclass[1]-1)]]


indices = lonarr(nptsclass[2])
indices = (randomu(seed, nptsclass[2]) * nptsclass[2])
indices = sort(indices)
tef_train = tef[*,indices[0:(nptstrain[2]-1)]]
tef_test= tef[*, indices[nptstrain[2]:(nptsclass[2]-1)]]


indices = lonarr(nptsclass[3])
indices = (randomu(seed, nptsclass[3]) * nptsclass[3])
indices = sort(indices)
psw_train = psw[*,indices[0:(nptstrain[3]-1)]]
psw_test= psw[*, indices[nptstrain[3]:(nptsclass[3]-1)]]


indices = lonarr(nptsclass[4])
indices = (randomu(seed, nptsclass[4]) * nptsclass[4])
indices = sort(indices)
hsw_train = hsw[*,indices[0:(nptstrain[4]-1)]]
hsw_test= hsw[*, indices[nptstrain[4]:(nptsclass[4]-1)]]



print, "wat_train", wat_train
print, "wat_test", wat_test

; calculate parameters for max likelihood classifier

envi_convert_file_coordinates, datafid, xf, yf, wat_train[1,*], wat_train[0,*]

      xf = fix(xf)
      yf = fix(yf)
      ; ADD THIS BIT OF CODE ONCE FOR EACH CLASS, WITH BOTTOM SETS GOING UP FROM 0 TO 1 ETC
      print, "doing water conversion"
	  PRINT, "XF", XF
	  PRINT, "Yf", YF
      spectraldatatemp=fltarr(nbands, nptstrain[0])
      For i=0, nptstrain[0]-1 do begin
        spectraldatatemp[*,i]=data[xf[i],yf[i],*]
      Endfor
      
      spectralmeans[*,0]=mean(spectraldatatemp, dimension=2)
      spectralstdv[*,0]=stddev(spectraldatatemp, dimension=2)
      spectralcov[*,*,0]=correlate(spectraldatatemp, /covariance)


envi_convert_file_coordinates, datafid, xf, yf, sav_train[1,*], sav_train[0,*]

xf = fix(xf)
yf = fix(yf)
print, "doing sav"

      spectraldatatemp=fltarr(nbands, nptstrain[1])
      For i=0, nptstrain[1]-1 do begin
        spectraldatatemp[*,i]=data[xf[i],yf[i],*]
      Endfor
      
      spectralmeans[*,1]=mean(spectraldatatemp, dimension=2)
      spectralstdv[*,1]=stddev(spectraldatatemp, dimension=2)
      spectralcov[*,*,1]=correlate(spectraldatatemp, /covariance)


envi_convert_file_coordinates, datafid, xf, yf, tef_train[1,*], tef_train[0,*]

xf = fix(xf)
yf = fix(yf)

      spectraldatatemp=fltarr(nbands, nptstrain[2])
      For i=0, nptstrain[2]-1 do begin
        spectraldatatemp[*,i]=data[xf[i],yf[i],*]
      Endfor
      
      spectralmeans[*,2]=mean(spectraldatatemp, dimension=2)
      spectralstdv[*,2]=stddev(spectraldatatemp, dimension=2)
      spectralcov[*,*,2]=correlate(spectraldatatemp, /covariance)


envi_convert_file_coordinates, datafid, xf, yf, psw_train[1,*], psw_train[0,*]

xf = fix(xf)
yf = fix(yf)

      spectraldatatemp=fltarr(nbands,nptstrain[3])
      For i=0, nptstrain[3]-1 do begin
        spectraldatatemp[*,i]=data[xf[i],yf[i],*]
      Endfor
      
      spectralmeans[*,3]=mean(spectraldatatemp, dimension=2)
      spectralstdv[*,3]=stddev(spectraldatatemp, dimension=2)
      spectralcov[*,*,3]=correlate(spectraldatatemp, /covariance)


envi_convert_file_coordinates, datafid, xf, yf, hsw_train[1,*], hsw_train[0,*]

xf = fix(xf)
yf = fix(yf)

      spectraldatatemp=fltarr(nbands, nptstrain[4])
      For i=0, nptstrain[4]-1 do begin
        spectraldatatemp[*,i]=data[xf[i],yf[i],*]
      Endfor
      
      spectralmeans[*,4]=mean(spectraldatatemp, dimension=2)
      spectralstdv[*,4]=stddev(spectraldatatemp, dimension=2)
      spectralcov[*,*,4]=correlate(spectraldatatemp, /covariance)


 ;help, spectralmeans
 print, spectralmeans[0,*]
 ;help, spectralstdv
 print, spectralstdv[0,*]
 ;help, spectralcov
print, spectralcov[0,*]


      
; perform max liklihood classifier
print, "doing classification"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DO CLASSIFICATION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
envi_doit, 'class_doit', DATA_SCALE=255, fid=datafid, pos=pos, dims=dims, out_bname='Max_likelihood', IN_MEMORY=1, method=2, mean=spectralmeans, stdv=spectralstdv, r_fid=outfid, lookup=lookup, cov=spectralcov, class_names=classnames1, num_classes=nclasses   
;envi_open_file, "F:\ENVI_IDL_CLASSIFICATION_FILES\output\exampleclassification", r_fid=outfid 

; read output map
pos1=[0]
outmap = envi_get_data(fid=outfid, dims=dims, pos=pos1)

;;;; write area for each class in this run

areatemp = lonarr(nclasses)

For ii = 0, nclasses-1 do begin
  areatemp[ii]=n_elements(where(outmap eq (ii+1)))
Endfor

printf, 9, areatemp



; get test statistics and write to text file - 
;;;;;;;;;;; REPEAT x 5
          envi_convert_file_coordinates, datafid, xf, yf, wat_test[1,*], wat_test[0,*]
          xf = fix(xf)
          yf = fix(yf)                     
          testclassestemp=bytarr(nptstest[0])
          For i=0, nptstest[0]-1 do begin
            testclassestemp[i]=outmap[xf[i],yf[i]]
          Endfor
			printf, 8, z, "wat", testclassestemp			  
            accuracy[0]=mean(testclassestemp eq 1)        
          
        
                                                                                                                    
        
          envi_convert_file_coordinates, datafid, xf, yf, sav_test[1,*], sav_test[0,*]
          xf = fix(xf)
          yf = fix(yf)
          testclassestemp=bytarr(nptstest[1])
          For i=0, nptstest[1]-1 do begin
            testclassestemp[i]=outmap[xf[i],yf[i]]
          Endfor

			printf, 8, z, "sav", testclassestemp	          
          accuracy[1]=mean(testclassestemp eq 2)
          
          envi_convert_file_coordinates, datafid, xf, yf, tef_test[1,*], tef_test[0,*]
          xf = fix(xf)
          yf = fix(yf)
          testclassestemp=bytarr(nptstest[2])
          For i=0, nptstest[2]-1 do begin
            testclassestemp[i]=outmap[xf[i],yf[i]]
          Endfor
          
			printf, 8, z, "tef", testclassestemp		  
          accuracy[2]=mean(testclassestemp eq 3)
          
          
          
          envi_convert_file_coordinates, datafid, xf, yf, psw_test[1,*], psw_test[0,*]
          xf = fix(xf)
          yf = fix(yf)
          testclassestemp=bytarr(nptstest[3])
          For i=0, nptstest[3]-1 do begin
            testclassestemp[i]=outmap[xf[i],yf[i]]
          Endfor
          
		  printf, 8, z, "psw", testclassestemp
          accuracy[3]=mean(testclassestemp eq 4)
          
          envi_convert_file_coordinates, datafid, xf, yf, hsw_test[1,*], hsw_test[0,*]
          xf = fix(xf)
          yf = fix(yf)
          testclassestemp=bytarr(nptstest[4])
          For i=0, nptstest[4]-1 do begin
            testclassestemp[i]=outmap[xf[i],yf[i]]
          Endfor
          
          print, testclassestemp
		  printf, 8, z, "hsw", testclassestemp
          
          accuracy[4]=mean(testclassestemp eq 5)
         ;;;;;;;;;;;;;;;;;;;;;;; end repeat


printf, 7, z, accuracy




        For j=1,nclasses do begin 
          outfilename=outfolderpath+"\Count_class_type_"+classnames[j-1]
          openr, j, outfilename
          readu, j, outtemp
          close, j
          openw, j, outfilename
          writeu, j, outtemp+(outmap eq j)
          close, j
        Endfor

envi_file_mng, id=outfid, /REMOVE

endfor 

close, /all

end



REPORT zmodel_alv.

DATA:
  im_change TYPE /yga/charm_change          VALUE '2000048012',
  im_status TYPE /yga/transp_ctrl-status_cd VALUE 'Aprovado'.

DATA(message_list) = cf_reca_message_list=>create( id_object    = '/YGA/JUMP'
                                                   id_subobject = 'TRANSP_CTRL'
                                                   id_extnumber = CONV balnrext( im_change )
                                                   id_deldate   = |{ sy-datum + 90 }| ).
IF message_list IS NOT BOUND.
  RETURN .
ENDIF .

message_list->add( id_msgty = if_xo_const_message=>info
                   id_msgid = '>0'
                   id_msgno = '000'
                   id_msgv1 = |O Status do CD { im_change }|
                   id_msgv2 = |foi alterado p/ { im_status }|
                   id_msgv3 = |({ sy-uname } { sy-datum DATE = USER } { sy-uzeit TIME = USER }).| ).

message_list->store( ).
IF sy-subrc = 0.
  COMMIT WORK AND WAIT .
ENDIF.
library;

import 'dart:convert';
import 'dart:io';

import 'dart:math' as math;
import 'package:event/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:gsd_restapi/gsd_restapi.dart';
import 'package:gsd_utilities/localstorage/gsdweblocalstoragemanagerdummy.dart'
    if (dart.library.html) 'package:gsd_utilities/localstorage/gsdweblocalstoragemanager.dart';
import 'package:gsd_utilities/uri/gsdweburimanagerdummy.dart'
    if (dart.library.html) 'package:gsd_utilities/uri/gsdweburimanager.dart';
import 'package:gsd_utilities/notifications/gsdwebnotificationhelperdummy.dart'
    if (dart.library.html) 'package:gsd_utilities/notifications/gsdwebnotificationshelper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gsd_encryption/gsd_encryption.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

part 'config/gsdbaseconfig.dart';
part 'config/gsdconfigmanager.dart';
part 'config/gsdappconfigmanager.dart';
part 'config/gsdwebconfigmanager.dart';
part 'config/gsdconfigresult.dart';
part 'config/gsdconfigchangedeventargs.dart';
part 'localstorage/gsdlocalstorageeventargs.dart';
part 'localstorage/gsdlocalstoragemanager.dart';
part 'localstorage/gsdbaselocalstoragemanager.dart';
part 'uri/gsdbaseurimanager.dart';
part 'uri/gsdurimanager.dart';
part 'notifications/gsdbasenotificationhelper.dart';
part 'notifications/gsdnotificationhelper.dart';
part 'docuframe/docuframeaccount.dart';
part 'docuframe/docuframeuploadmanager.dart';
part 'upload/gsduploadfile.dart';
part 'upload/gsduploadfileresult.dart';
part 'upload/gsduploadimageresolution.dart';
part 'upload/gsduploadresult.dart';
part 'upload/gsduploadfileprogress.dart';
part 'upload/gsduploadfileprogressstatus.dart';
part 'upload/gsduploadprogress.dart';
part 'multilanguage/gsdlanguage.dart';
part 'multilanguage/gsdmultilangaugeprovider.dart';
part 'multilanguage/interface/igsdmultilanguagedataprovider.dart';
part 'multilanguage/interface/igsdmultilanguageconfigprovider.dart';
part 'multilanguage/interface/igsdmultilanguageanalyticsprovider.dart';
part 'extension.dart';

import { Upload, FileText, Check, X, AlertCircle } from 'lucide-react';
import { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';

interface PaymentUploadProps {
  eventId: string | null;
  onComplete: () => void;
}

export function PaymentUpload({ eventId, onComplete }: PaymentUploadProps) {
  const [uploadedFile, setUploadedFile] = useState<File | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [uploadSuccess, setUploadSuccess] = useState(false);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setUploadedFile(e.target.files[0]);
    }
  };

  const handleUpload = () => {
    if (!uploadedFile) return;
    
    setIsUploading(true);
    // Simulate upload
    setTimeout(() => {
      setIsUploading(false);
      setUploadSuccess(true);
      
      // Auto redirect after 2 seconds
      setTimeout(() => {
        onComplete();
      }, 2000);
    }, 2000);
  };

  const handleRemoveFile = () => {
    setUploadedFile(null);
  };

  return (
    <div className="min-h-screen pb-6">
      {/* Header */}
      <motion.div 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-gradient-to-br from-blue-600 via-indigo-600 to-purple-600 text-white px-6 pt-12 pb-8 relative overflow-hidden"
      >
        <motion.div
          animate={{
            scale: [1, 1.3, 1],
            y: [-20, 20, -20],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut"
          }}
          className="absolute -bottom-10 -left-10 w-40 h-40 bg-white/10 rounded-full blur-3xl"
        />

        <div className="relative z-10">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: "spring", delay: 0.2 }}
            className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-sm px-3 py-1.5 rounded-full mb-3"
          >
            <FileText className="w-3.5 h-3.5" />
            <span className="text-xs font-medium">Payment Required</span>
          </motion.div>
          <h1 className="text-3xl font-bold">Upload Invoice</h1>
          <p className="text-purple-100 text-sm mt-2">Upload your payment proof to activate the event</p>
        </div>
      </motion.div>

      {/* Content */}
      <div className="px-6 py-6 space-y-6">
        {/* Info Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-blue-50 rounded-2xl p-4 flex items-start gap-3"
        >
          <div className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center flex-shrink-0">
            <AlertCircle className="w-5 h-5 text-white" />
          </div>
          <div>
            <h3 className="font-bold text-gray-900 mb-1">Payment Instructions</h3>
            <p className="text-sm text-gray-600">
              Please upload a clear photo or PDF of your payment invoice/receipt. 
              Once verified, your event will be activated within 24 hours.
            </p>
          </div>
        </motion.div>

        {/* Upload Area */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.2 }}
          className="bg-white rounded-3xl p-6 shadow-xl"
        >
          <AnimatePresence mode="wait">
            {!uploadedFile ? (
              <motion.label
                key="upload"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                htmlFor="file-upload"
                className="block cursor-pointer"
              >
                <div className="border-3 border-dashed border-gray-300 rounded-2xl p-8 text-center hover:border-purple-500 transition-colors">
                  <motion.div
                    animate={{
                      y: [0, -10, 0],
                    }}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                      ease: "easeInOut"
                    }}
                    className="w-20 h-20 bg-gradient-to-br from-purple-100 to-pink-100 rounded-full flex items-center justify-center mx-auto mb-4"
                  >
                    <Upload className="w-10 h-10 text-purple-600" />
                  </motion.div>
                  <h3 className="font-bold text-gray-900 mb-2">Upload Invoice</h3>
                  <p className="text-sm text-gray-600 mb-4">
                    Click to select or drag and drop
                  </p>
                  <p className="text-xs text-gray-500">
                    Supported: PDF, JPG, PNG (Max 10MB)
                  </p>
                </div>
                <input
                  id="file-upload"
                  type="file"
                  accept=".pdf,.jpg,.jpeg,.png"
                  onChange={handleFileSelect}
                  className="hidden"
                />
              </motion.label>
            ) : uploadSuccess ? (
              <motion.div
                key="success"
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                className="text-center py-8"
              >
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ type: "spring", delay: 0.2 }}
                  className="w-24 h-24 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4"
                >
                  <Check className="w-12 h-12 text-white" />
                </motion.div>
                <h3 className="text-2xl font-bold text-gray-900 mb-2">Upload Successful!</h3>
                <p className="text-sm text-gray-600">
                  Your invoice has been submitted. Redirecting...
                </p>
              </motion.div>
            ) : (
              <motion.div
                key="preview"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
              >
                <div className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl p-6">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex items-start gap-3">
                      <div className="w-12 h-12 bg-gradient-to-br from-purple-600 to-pink-600 rounded-xl flex items-center justify-center">
                        <FileText className="w-6 h-6 text-white" />
                      </div>
                      <div>
                        <h3 className="font-bold text-gray-900">{uploadedFile.name}</h3>
                        <p className="text-sm text-gray-600 mt-0.5">
                          {(uploadedFile.size / 1024 / 1024).toFixed(2)} MB
                        </p>
                      </div>
                    </div>
                    <motion.button
                      whileTap={{ scale: 0.9 }}
                      onClick={handleRemoveFile}
                      className="w-8 h-8 bg-white rounded-full flex items-center justify-center shadow-md"
                    >
                      <X className="w-4 h-4 text-gray-600" />
                    </motion.button>
                  </div>

                  {isUploading && (
                    <div className="space-y-2">
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Uploading...</span>
                        <span className="font-bold text-purple-600">75%</span>
                      </div>
                      <div className="h-2 bg-white rounded-full overflow-hidden">
                        <motion.div
                          initial={{ width: 0 }}
                          animate={{ width: '75%' }}
                          transition={{ duration: 1.5 }}
                          className="h-full bg-gradient-to-r from-purple-600 to-pink-600 rounded-full"
                        />
                      </div>
                    </div>
                  )}
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </motion.div>

        {/* Payment Details */}
        {!uploadSuccess && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="bg-white rounded-3xl p-6 shadow-xl"
          >
            <h3 className="font-bold text-gray-900 mb-4">Bank Transfer Details</h3>
            <div className="space-y-3 bg-gray-50 rounded-2xl p-4">
              <div>
                <p className="text-xs text-gray-600">Bank Name</p>
                <p className="font-bold text-gray-900">Al Rajhi Bank</p>
              </div>
              <div>
                <p className="text-xs text-gray-600">Account Name</p>
                <p className="font-bold text-gray-900">Koroot Events LLC</p>
              </div>
              <div>
                <p className="text-xs text-gray-600">Account Number</p>
                <p className="font-bold text-gray-900">SA12 3456 7890 1234 5678</p>
              </div>
              <div>
                <p className="text-xs text-gray-600">Amount</p>
                <p className="text-2xl font-bold text-purple-600">599 SAR</p>
              </div>
            </div>
          </motion.div>
        )}

        {/* Upload Button */}
        {uploadedFile && !uploadSuccess && (
          <motion.button
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={handleUpload}
            disabled={isUploading}
            className={`w-full py-4 rounded-2xl font-bold shadow-xl transition-all ${
              isUploading
                ? 'bg-gray-300 text-gray-500'
                : 'bg-gradient-to-r from-purple-600 to-pink-600 text-white'
            }`}
          >
            {isUploading ? 'Uploading...' : 'Submit Invoice'}
          </motion.button>
        )}

        {/* Skip for now */}
        {!uploadSuccess && (
          <motion.button
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.4 }}
            onClick={onComplete}
            className="w-full py-3 text-gray-600 font-medium text-sm"
          >
            Skip for now (Event will remain as Draft)
          </motion.button>
        )}
      </div>
    </div>
  );
}

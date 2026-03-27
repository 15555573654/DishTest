package com.ruoyi.screencast.crash

import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.ListView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.ruoyi.screencast.R
import java.io.File

/**
 * 崩溃日志查看Activity
 */
class CrashLogActivity : AppCompatActivity() {

    private lateinit var listView: ListView
    private val logFiles = mutableListOf<File>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 创建简单的ListView布局
        listView = ListView(this)
        setContentView(listView)
        
        title = "崩溃日志"
        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        loadCrashLogs()
        setupListView()
    }

    private fun loadCrashLogs() {
        val logDir = CrashHandler.getInstance().getCrashLogDir()
        if (logDir?.exists() == true) {
            logFiles.clear()
            logDir.listFiles()?.sortedByDescending { it.lastModified() }?.let {
                logFiles.addAll(it)
            }
        }
    }

    private fun setupListView() {
        if (logFiles.isEmpty()) {
            Toast.makeText(this, "没有崩溃日志", Toast.LENGTH_SHORT).show()
            finish()
            return
        }

        val fileNames = logFiles.map { it.name }
        val adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, fileNames)
        listView.adapter = adapter

        listView.setOnItemClickListener { _, _, position, _ ->
            showLogContent(logFiles[position])
        }

        listView.setOnItemLongClickListener { _, _, position, _ ->
            showDeleteDialog(logFiles[position], position)
            true
        }
    }

    private fun showLogContent(logFile: File) {
        try {
            val content = logFile.readText()
            AlertDialog.Builder(this)
                .setTitle(logFile.name)
                .setMessage(content)
                .setPositiveButton("关闭", null)
                .setNegativeButton("删除") { _, _ ->
                    deleteLog(logFile)
                }
                .show()
        } catch (e: Exception) {
            Toast.makeText(this, "读取日志失败: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    private fun showDeleteDialog(logFile: File, position: Int) {
        AlertDialog.Builder(this)
            .setTitle("删除日志")
            .setMessage("确定要删除 ${logFile.name} 吗？")
            .setPositiveButton("删除") { _, _ ->
                deleteLog(logFile)
            }
            .setNegativeButton("取消", null)
            .show()
    }

    private fun deleteLog(logFile: File) {
        try {
            if (logFile.delete()) {
                Toast.makeText(this, "已删除", Toast.LENGTH_SHORT).show()
                loadCrashLogs()
                setupListView()
            } else {
                Toast.makeText(this, "删除失败", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            Toast.makeText(this, "删除失败: ${e.message}", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        finish()
        return true
    }
}
